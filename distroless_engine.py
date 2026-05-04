import os
import yaml
import json
import argparse
import urllib.request
import tempfile
import re

ARCH_GITLAB_BASE = "https://gitlab.archlinux.org/archlinux/packaging/packages/{}/-/raw/main/PKGBUILD"

class MetadataManager:
    def __init__(self, cache_dir):
        self.cache_dir = cache_dir
        self.hardcoded_sources = {
            "zlib": "https://github.com/madler/zlib/archive/refs/tags/v1.3.1.tar.gz",
            "openssl": "https://github.com/openssl/openssl/releases/download/openssl-3.4.0/openssl-3.4.0.tar.gz",
            "ncurses": "https://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.5.tar.gz",
            "readline": "https://ftp.gnu.org/pub/gnu/readline/readline-8.2.tar.gz",
            "sqlite": "https://www.sqlite.org/2024/sqlite-autoconf-3470000.tar.gz",
            "libxcrypt": "https://github.com/besser82/libxcrypt/releases/download/v4.4.36/libxcrypt-4.4.36.tar.xz",
            "libffi": "https://github.com/libffi/libffi/releases/download/v3.4.6/libffi-3.4.6.tar.gz",
            "expat": "https://github.com/libexpat/libexpat/releases/download/R_2_6_4/expat-2.6.4.tar.xz",
            "bzip2": "https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz",
            "xz": "https://github.com/tukaani-project/xz/releases/download/v5.6.3/xz-5.6.3.tar.xz",
            "gdbm": "https://ftp.gnu.org/pub/gnu/gdbm/gdbm-1.24.tar.gz"
        }

    def fetch_arch_pkgbuild(self, pkgname):
        url = ARCH_GITLAB_BASE.format(pkgname)
        dest = os.path.join(self.cache_dir, f"{pkgname}_PKGBUILD")
        try:
            urllib.request.urlretrieve(url, dest)
            return dest
        except Exception:
            return None

    def parse_pkgbuild(self, content):
        metadata = {"depends": []}
        
        # Extract dependencies
        depends_match = re.search(r'depends=\((.*?)\)', content, re.DOTALL)
        if depends_match:
            deps_str = depends_match.group(1).replace('"', '').replace("'", "")
            metadata["depends"] = [d.split('>')[0].split('<')[0].split('=')[0].strip() for d in deps_str.split() if d.strip()]

        return metadata

    def get_metadata(self, pkgname):
        res = {
            "url": self.hardcoded_sources.get(pkgname, "SKIP"),
            "sha": "SKIP",
            "depends": []
        }
        
        pkgbuild_path = self.fetch_arch_pkgbuild(pkgname)
        if pkgbuild_path:
            with open(pkgbuild_path, 'r') as f:
                content = f.read()
            info = self.parse_pkgbuild(content)
            res["depends"] = info["depends"]
            
        return res

class DAGResolver:
    def __init__(self, manager):
        self.manager = manager
        self.graph = {}

    def resolve(self, initial_packages):
        visited = set()
        stack = list(initial_packages)
        
        print(f"🔍 Starting dependency resolution for: {initial_packages}")
        
        while stack:
            pkg = stack.pop(0)
            if pkg in visited: continue
            visited.add(pkg)
            
            meta = self.manager.get_metadata(pkg)
            if not meta:
                print(f"⚠️ Could not resolve metadata for {pkg}")
                continue
            
            self.graph[pkg] = meta
            print(f"✅ Resolved {pkg} (depends on: {meta['depends']})")
            
            for dep in meta['depends']:
                # Only resolve internal dependencies that we know how to build or that are in our hardcoded list
                if dep in self.manager.hardcoded_sources:
                    stack.append(dep)

class HCLGenerator:
    def __init__(self, stack_config):
        self.stack = stack_config
        self.platform = "linux/amd64"
        self.has_stack_target = stack_config.get("type") == "source_build"

    def generate(self, graph):
        hcl = 'variable "REGISTRY" {\n  default = "ghcr.io/mbuccarello"\n}\n\n'
        
        hcl += 'group "default" {\n'
        hcl += '  targets = ["runtime", "runtime-debug"]\n'
        hcl += '}\n\n'

        # Base builder target
        hcl += 'target "builder" {\n  dockerfile = "Dockerfile"\n  target = "builder"\n  context = "."\n'
        hcl += f'  platforms = ["{self.platform}"]\n}}\n\n'

        # Library targets (now point to Dockerfile.cc)
        for pkg, meta in graph.items():
            hcl += f'target "{pkg}" {{\n'
            hcl += '  dockerfile = "Dockerfile.cc"\n'
            hcl += f'  target = "{pkg}-builder"\n'
            hcl += '  context = "."\n'
            hcl += f'  platforms = ["{self.platform}"]\n'
            hcl += '  args = {\n'
            hcl += f'    LIB_NAME = "{pkg}"\n'
            hcl += f'    LIB_URL = "{meta["url"]}"\n'
            
            # Smart Overrides for LIB_CONFIG
            lib_config = ""
            if pkg == "zlib": lib_config = "--shared"
            if pkg == "openssl": lib_config = "shared zlib"
            if pkg == "ncurses": lib_config = "--with-shared --enable-widec --enable-pc-files --with-termlib"
            if pkg == "readline": lib_config = "--with-curses"
            if pkg == "libxcrypt": lib_config = "--disable-werror"
            
            if lib_config:
                hcl += f'    LIB_CONFIG = "{lib_config}"\n'
            
            hcl += '  }\n'
            hcl += '  contexts = {\n'
            hcl += '    builder = "target:builder"\n'
            # Add dependency contexts
            for dep in meta['depends']:
                if dep in graph:
                    hcl += f'    {dep} = "target:{dep}"\n'
            hcl += '  }\n'
            hcl += '}\n\n'

        # Stack-specific target (if any)
        if self.has_stack_target:
            hcl += f'target "{self.stack["name"]}" {{\n'
            hcl += '  dockerfile = "Dockerfile.cc"\n'
            hcl += f'  target = "stack-builder"\n'
            hcl += '  context = "."\n'
            hcl += f'  platforms = ["{self.platform}"]\n'
            hcl += '  args = {\n'
            hcl += f'    STACK_NAME = "{self.stack["name"]}"\n'
            hcl += f'    STACK_URL = "{self.stack["runtime"]["source_url"]}"\n'
            hcl += f'    STACK_CONFIG = "{ " ".join(self.stack["runtime"].get("build_flags", [])) }"\n'
            hcl += '  }\n'
            hcl += '  contexts = {\n'
            hcl += '    builder = "target:builder"\n'
            for pkg in graph.keys():
                hcl += f'    {pkg} = "target:{pkg}"\n'
            hcl += '  }\n'
            hcl += '}\n\n'

        # Final images
        hcl += 'target "static" {\n  dockerfile = "Dockerfile"\n  target = "static"\n  context = "."\n}\n\n'
        hcl += 'target "base" {\n  dockerfile = "Dockerfile"\n  target = "base"\n  context = "."\n}\n\n'

        hcl += 'target "cc" {\n  dockerfile = "Dockerfile.cc"\n  target = "cc"\n  context = "."\n'
        hcl += '  contexts = {\n    base = "target:base"\n    builder = "target:builder"\n'
        for pkg in graph.keys():
            hcl += f'    {pkg} = "target:{pkg}"\n'
        hcl += '  }\n}\n\n'

        hcl += 'target "runtime" {\n  inherits = ["cc"]\n  target = "runtime"\n'
        hcl += '  args = {\n'
        hcl += f'    RUNTIME_NAME = "{self.stack["name"]}"\n'
        hcl += f'    RUNTIME_VER = "{self.stack["version"]}"\n'
        if self.stack.get("type") == "binary_injection":
            hcl += f'    RUNTIME_URL = "{self.stack["runtime"]["binary_url"]}"\n'
        hcl += '  }\n'
        hcl += '  contexts = {\n'
        if self.has_stack_target:
            hcl += f'    {self.stack["name"]} = "target:{self.stack["name"]}"\n'
        hcl += '  }\n'
        hcl += '  tags = ["${REGISTRY}/' + self.stack["name"] + '-distroless:latest"]\n}\n\n'

        hcl += 'target "runtime-debug" {\n  inherits = ["runtime"]\n  target = "runtime-debug"\n'
        hcl += '  tags = ["${REGISTRY}/' + self.stack["name"] + '-distroless:debug"]\n}\n'

        return hcl

    def generate_cc_dockerfile(self, graph):
        # No syntax header for secondary Dockerfile used by Bake
        df = ""
        
        # Template for library builders
        for pkg, meta in graph.items():
            df += f"\nFROM builder as {pkg}-builder\n"
            df += f"ARG LIB_NAME={pkg}\nARG LIB_URL\nARG LIB_CONFIG\n"
            
            # Copy dependencies to /usr (using context names from HCL)
            for dep in meta['depends']:
                if dep in graph:
                    df += f"COPY --from={dep} /artifacts/usr /usr\n"
            
            df += "WORKDIR /build\n"
            df += "RUN if [ -n \"$LIB_URL\" ] && [ \"$LIB_URL\" != \"SKIP\" ]; then \\\n"
            df += "    curl -L \"$LIB_URL\" -o source.tar.gz && \\\n"
            df += "    mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && \\\n"
            df += "    cd src && \\\n"
            # Smart build command
            df += "    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; \\\n"
            df += "    elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; \\\n"
            df += "    fi && \\\n"
            df += "    if [ \"$LIB_NAME\" = \"bzip2\" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; \\\n"
            df += "    else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \\\n"
            df += "    fi\n"
            # Ensure artifacts/usr exists even if build skipped
            df += "RUN mkdir -p /artifacts/usr\n"

        # Stack builder stage
        if self.has_stack_target:
            df += f"\nFROM builder as stack-builder\n"
            df += "ARG STACK_NAME\nARG STACK_URL\nARG STACK_CONFIG\n"
            for pkg in graph.keys():
                df += f"COPY --from={pkg} /artifacts/usr /usr\n"
            
            df += "WORKDIR /build\n"
            df += "RUN if [ -n \"$STACK_URL\" ] && [ \"$STACK_URL\" != \"SKIP\" ]; then \\\n"
            df += "    curl -L \"$STACK_URL\" -o source.tar.xz && \\\n"
            df += "    mkdir src && tar -xf source.tar.xz -C src --strip-components=1 && \\\n"
            df += "    cd src && \\\n"
            df += "    ./configure --prefix=/usr $STACK_CONFIG && \\\n"
            df += "    make -j$(nproc) && \\\n"
            df += "    make DESTDIR=/artifacts install; \\\n"
            df += "    fi\n"

        # Intermediate setup stage (for validation)
        df += "\nFROM builder as runtime-setup\nUSER root\n"
        df += "RUN mkdir -p /runtime-root/usr\n"
        for pkg in graph.keys():
            df += f"COPY --from={pkg} /artifacts/usr /runtime-root/usr\n"
        
        if self.stack.get("type") == "binary_injection":
            df += "ARG RUNTIME_URL\n"
            df += "RUN curl -L \"$RUNTIME_URL\" -o /tmp/runtime.tar.gz && \\\n"
            df += "    tar -xf /tmp/runtime.tar.gz -C /runtime-root/usr --strip-components=1\n"
        elif self.has_stack_target:
            df += f"COPY --from=stack-builder /artifacts/usr /runtime-root/usr\n"

        # Automated Linkage Validation
        df += "RUN find /runtime-root/usr/lib -maxdepth 2 || true\n"
        df += "RUN if [ -f /runtime-root/usr/bin/python3 ]; then LD_LIBRARY_PATH=/runtime-root/usr/lib /lib64/ld-linux-x86-64.so.2 --list /runtime-root/usr/bin/python3; fi\n"
        df += "RUN if [ -f /runtime-root/usr/bin/node ]; then LD_LIBRARY_PATH=/runtime-root/usr/lib /lib64/ld-linux-x86-64.so.2 --list /runtime-root/usr/bin/node; fi\n"

        # Final CC image
        df += "\nFROM base as cc\nUSER root\n"
        # Fedora uses lib64 for libgcc/libstdc++
        df += "COPY --from=builder /usr/lib64/libgcc_s.so.1 /usr/lib/\n"
        df += "COPY --from=builder /usr/lib64/libstdc++.so.6 /usr/lib/\n"
        for pkg in graph.keys():
            df += f"COPY --from={pkg} /artifacts/usr /usr\n"
        
        df += "\nFROM cc as runtime\nUSER root\nARG RUNTIME_NAME\nARG RUNTIME_VER\nLABEL distroless.stack=\"${RUNTIME_NAME}\"\n"
        df += "COPY --from=runtime-setup /runtime-root/usr /usr\n"
        df += "USER 65532:65532\n"
        
        df += "\nFROM runtime as runtime-debug\nUSER root\n"
        df += "COPY --from=builder /usr/bin/busybox /usr/bin/busybox\n"
        df += "RUN [\"/usr/bin/busybox\", \"--install\", \"-s\", \"/usr/bin\"]\nUSER 65532:65532\n"
        
        return df

def main():
    parser = argparse.ArgumentParser(description="Distroless Build Engine")
    parser.add_argument("--stack", required=True, help="Path to stack YAML config")
    parser.add_argument("--graph", action="store_true", help="Generate dependency graph diagram")
    args = parser.parse_args()

    with open(args.stack, 'r') as f:
        stack_config = yaml.safe_load(f)

    print(f"🚀 Initializing Distroless Engine for {stack_config['name']}...")
    
    with tempfile.TemporaryDirectory() as tmpdir:
        manager = MetadataManager(tmpdir)
        resolver = DAGResolver(manager)
        deps = stack_config.get('dependencies', [])
        if deps:
            resolver.resolve([d['name'] for d in deps])
        
        generator = HCLGenerator(stack_config)
        hcl = generator.generate(resolver.graph)
        
        with open("docker-bake.hcl", "w") as f:
            f.write(hcl)
        print(f"✅ Generated docker-bake.hcl")

        df_cc = generator.generate_cc_dockerfile(resolver.graph)
        with open("Dockerfile.cc", "w") as f:
            f.write(df_cc)
        print(f"✅ Generated Dockerfile.cc")

if __name__ == "__main__":
    main()
