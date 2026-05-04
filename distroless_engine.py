#!/usr/bin/env python3
import yaml
import urllib.request
import subprocess
import os
import tempfile
import sys
import re
import argparse

# Unified Distroless Engine Configuration
ARCH_GITLAB_BASE = "https://gitlab.archlinux.org/archlinux/packaging/packages/{}/-/raw/main/PKGBUILD"

class MetadataManager:
    def __init__(self, cache_dir):
        self.cache_dir = cache_dir
        os.makedirs(cache_dir, exist_ok=True)
        self.hardcoded_sources = {
            "expat": "https://github.com/libexpat/libexpat/releases/download/R_2_6_4/expat-2.6.4.tar.bz2",
            "gdbm": "https://ftp.gnu.org/gnu/gdbm/gdbm-1.24.tar.gz",
            "zlib": "https://www.zlib.net/zlib-1.3.1.tar.gz",
            "openssl": "https://www.openssl.org/source/openssl-3.4.0.tar.gz",
            "libffi": "https://github.com/libffi/libffi/releases/download/v3.4.6/libffi-3.4.6.tar.gz",
            "bzip2": "https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz",
            "xz": "https://tukaani.org/xz/xz-5.6.3.tar.gz",
            "ncurses": "https://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.5.tar.gz",
            "readline": "https://ftp.gnu.org/gnu/readline/readline-8.2.tar.gz",
            "sqlite": "https://www.sqlite.org/2024/sqlite-autoconf-3470000.tar.gz",
            "libxcrypt": "https://github.com/besser82/libxcrypt/releases/download/v4.4.36/libxcrypt-4.4.36.tar.xz",
            "icu": "https://github.com/unicode-org/icu/releases/download/release-75-1/icu4c-75_1-src.tgz",
            "brotli": "https://github.com/google/brotli/archive/refs/tags/v1.1.0.tar.gz",
            "c-ares": "https://github.com/c-ares/c-ares/releases/download/v1.34.2/c-ares-1.34.2.tar.gz",
            "nghttp2": "https://github.com/nghttp2/nghttp2/releases/download/v1.64.0/nghttp2-1.64.0.tar.gz",
            "krb5": "https://web.mit.edu/kerberos/dist/krb5/1.21/krb5-1.21.3.tar.gz",
            "oniguruma": "https://github.com/kkos/oniguruma/releases/download/v6.9.9/onig-6.9.9.tar.gz",
            "libxml2": "https://download.gnome.org/sources/libxml2/2.12/libxml2-2.12.9.tar.xz",
            "curl": "https://curl.se/download/curl-8.11.0.tar.xz"
        }

    def fetch_arch_pkgbuild(self, pkgname):
        url = ARCH_GITLAB_BASE.format(pkgname)
        dest = os.path.join(self.cache_dir, f"{pkgname}_PKGBUILD")
        try:
            urllib.request.urlretrieve(url, dest)
            return dest
        except Exception:
            return None

    def get_metadata(self, pkgname):
        if pkgname in self.hardcoded_sources:
            return {
                "url": self.hardcoded_sources[pkgname],
                "sha": "SKIP",
                "depends": []
            }

        pkgbuild_path = self.fetch_arch_pkgbuild(pkgname)
        if not pkgbuild_path:
            return None

        cmd = [
            "docker", "run", "--rm", "--platform", "linux/amd64",
            "-v", f"{os.path.dirname(os.path.abspath(pkgbuild_path))}:/pkg",
            "archlinux",
            "bash", "-c",
            f"cp /pkg/{os.path.basename(pkgbuild_path)} /tmp/PKGBUILD && cd /tmp && makepkg --printsrcinfo"
        ]
        result = subprocess.run(cmd, capture_output=True, text=True)
        srcinfo = result.stdout
        
        info = {"sources": [], "sha512sums": [], "depends": [], "url": None}
        
        for line in srcinfo.splitlines():
            line = line.strip()
            if line.startswith("source ="):
                src = line.split("=", 1)[1].strip()
                if "::" in src: src = src.split("::")[1]
                if src.startswith("http"):
                    info["sources"].append(src)
            elif line.startswith("sha512sums ="):
                info["sha512sums"].append(line.split("=", 1)[1].strip())
            elif line.startswith("depends ="):
                dep = line.split("=", 1)[1].strip()
                dep = re.split('[<>=]', dep)[0]
                info["depends"].append(dep)
            elif line.startswith("pkgbase ="):
                info["url"] = f"https://gitlab.archlinux.org/archlinux/packaging/packages/{line.split('=')[1].strip()}"
        
        main_url = info["sources"][0] if info["sources"] else info["url"]
        main_sha = info["sha512sums"][0] if info["sha512sums"] else "SKIP"
        
        return {
            "url": main_url,
            "sha": main_sha,
            "depends": info["depends"]
        }

class DAGResolver:
    def __init__(self, manager):
        self.manager = manager
        self.graph = {}

    def resolve(self, initial_packages):
        visited = set()
        stack = list(initial_packages)
        
        while stack:
            pkg = stack.pop(0)
            if pkg in visited: continue
            
            print(f"🔍 Resolving {pkg}...")
            meta = self.manager.get_metadata(pkg)
            if not meta: continue
            
            self.graph[pkg] = meta
            visited.add(pkg)
            for dep in meta["depends"]:
                if dep not in visited:
                    stack.append(dep)

class HCLGenerator:
    def __init__(self, stack_config):
        self.stack = stack_config
        self.registry = "ghcr.io/mbuccarello"
        self.platform = "linux/amd64"

    def generate(self, graph):
        hcl = f'# Generated by Distroless Engine\n'
        hcl += f'variable "REGISTRY" {{ default = "{self.registry}" }}\n\n'
        
        hcl += 'group "default" {\n  targets = ["runtime", "runtime-debug"]\n}\n\n'

        hcl += 'target "builder" {\n  dockerfile = "Dockerfile"\n  target = "builder"\n  context = "."\n'
        hcl += f'  platforms = ["{self.platform}"]\n}}\n\n'

        # Add targets for each dependency in the graph
        for pkg, data in graph.items():
            hcl += f'target "{pkg}" {{\n'
            hcl += '  dockerfile = "Dockerfile"\n'
            hcl += '  target = "lib-builder"\n'
            hcl += '  context = "."\n'
            hcl += f'  platforms = ["{self.platform}"]\n'
            # Smart Overrides for core libraries
            lib_config = ""
            make_extra = ""
            if pkg == "zlib":
                lib_config = "--shared"
            elif pkg == "openssl":
                lib_config = "shared zlib"
            elif pkg == "readline":
                lib_config = "--with-curses"
            elif pkg == "ncurses":
                lib_config = "--with-shared --without-debug --enable-widec --enable-pc-files --with-pkg-config-libdir=/usr/lib/pkgconfig"
            
            hcl += f'  args = {{\n'
            hcl += f'    LIB_NAME = "{pkg}"\n'
            if data["url"]: hcl += f'    LIB_URL = "{data["url"]}"\n'
            if data["sha"] and data["sha"] != "SKIP": hcl += f'    LIB_SHA = "{data["sha"]}"\n'
            if lib_config: hcl += f'    LIB_CONFIG = "{lib_config}"\n'
            if make_extra: hcl += f'    MAKE_EXTRA = "{make_extra}"\n'
            hcl += '  }\n'
            hcl += '  contexts = {\n'
            hcl += '    builder = "target:builder"\n'
            if data["depends"]:
                for dep in data["depends"]:
                    if dep in graph:
                        hcl += f'    {dep} = "target:{dep}"\n'
            hcl += '  }\n'
            hcl += '}\n\n'

        # Add the stack itself if it's a source build and has a source URL
        # Core stacks like 'static', 'base', 'cc' are handled separately.
        self.has_stack_target = False
        if self.stack.get("type") == "source_build" and "source_url" in self.stack.get("runtime", {}) and self.stack["name"] not in ["static", "base", "cc"]:
            self.has_stack_target = True
            hcl += f'target "{self.stack["name"]}" {{\n'
            hcl += '  dockerfile = "Dockerfile"\n'
            hcl += '  target = "lib-builder"\n'
            hcl += '  context = "."\n'
            hcl += f'  platforms = ["{self.platform}"]\n'
            hcl += f'  args = {{\n'
            hcl += f'    LIB_NAME = "{self.stack["name"]}"\n'
            hcl += f'    LIB_URL = "{self.stack["runtime"]["source_url"]}"\n'
            hcl += '  }\n'
            hcl += '  contexts = {\n'
            hcl += '    builder = "target:builder"\n'
            for pkg in graph.keys():
                hcl += f'    {pkg} = "target:{pkg}"\n'
            hcl += '  }\n'
            hcl += '}\n\n'

        hcl += 'target "static" {\n  dockerfile = "Dockerfile"\n  target = "static"\n  context = "."\n'
        hcl += f'  platforms = ["{self.platform}"]\n}}\n\n'

        hcl += 'target "static-debug" {\n  dockerfile = "Dockerfile"\n  target = "static-debug"\n  context = "."\n'
        hcl += f'  platforms = ["{self.platform}"]\n}}\n\n'

        hcl += 'target "base" {\n  inherits = ["static"]\n  target = "base"\n}\n\n'
        hcl += 'target "base-debug" {\n  inherits = ["static-debug"]\n  target = "base-debug"\n}\n\n'

        hcl += 'target "cc" {\n  dockerfile = "Dockerfile.cc"\n  context = "."\n'
        hcl += f'  platforms = ["{self.platform}"]\n'
        hcl += '  contexts = {\n'
        hcl += '    base = "target:base"\n'
        hcl += '    builder = "target:builder"\n'
        for pkg in graph.keys():
            hcl += f'    {pkg} = "target:{pkg}"\n'
        if self.has_stack_target:
            hcl += f'    {self.stack["name"]} = "target:{self.stack["name"]}"\n'
        hcl += '  }\n}\n\n'

        hcl += 'target "runtime" {\n  inherits = ["cc"]\n  target = "runtime"\n  args = {\n'
        hcl += f'    RUNTIME_NAME = "{self.stack["name"]}"\n'
        hcl += f'    RUNTIME_VER = "{self.stack["version"]}"\n'
        if self.stack.get("type") == "binary_injection":
            hcl += f'    RUNTIME_URL = "{self.stack["runtime"]["binary_url"]}"\n'
        hcl += '  }\n  tags = ["${REGISTRY}/' + self.stack["name"] + '-distroless:latest"]\n}\n\n'
        
        hcl += 'target "runtime-debug" {\n  inherits = ["cc"]\n  target = "runtime-debug"\n'
        hcl += '  tags = ["${REGISTRY}/' + self.stack["name"] + '-distroless:debug"]\n}\n'
        
        return hcl

    def generate_cc_dockerfile(self, graph):
        df = "# syntax=docker/dockerfile:1.4\n"
        
        # Intermediate setup stage (has shell/tools)
        df += "FROM builder as runtime-setup\nUSER root\n"
        df += "ARG RUNTIME_URL\nRUN mkdir -p /runtime-root/usr\n"
        
        # Add dependencies to runtime-setup for consistency (ISOLATED from builder /usr)
        for pkg in graph.keys():
            df += f"COPY --from={pkg} /artifacts/usr /runtime-root/usr\n"

        if self.stack.get("type") == "binary_injection":
            df += "RUN if [ -n \"$RUNTIME_URL\" ]; then \\\n"
            df += "    curl -L \"$RUNTIME_URL\" -o /tmp/runtime.tar.gz && \\\n"
            df += "    tar -xf /tmp/runtime.tar.gz -C /runtime-root/usr --strip-components=1; \\\n"
            df += "    fi\n"
        elif self.has_stack_target:
            # Copy from the stack-specific build stage
            df += f"COPY --from={self.stack['name']} /artifacts/usr /runtime-root/usr\n"

        # Automated Linkage Validation (using ld-linux directly to avoid shell corruption)
        df += "RUN if [ -f /runtime-root/usr/bin/python3 ]; then LD_LIBRARY_PATH=/runtime-root/usr/lib /lib64/ld-linux-x86-64.so.2 --list /runtime-root/usr/bin/python3; fi\n"
        df += "RUN if [ -f /runtime-root/usr/bin/node ]; then LD_LIBRARY_PATH=/runtime-root/usr/lib /lib64/ld-linux-x86-64.so.2 --list /runtime-root/usr/bin/node; fi\n"

        df += "\nFROM base as cc\nUSER root\n"
        df += "COPY --from=builder /usr/lib/libgcc_s.so.1 /usr/lib/\n"
        df += "COPY --from=builder /usr/lib/libstdc++.so.6 /usr/lib/\n"
        for pkg in graph.keys():
            df += f"COPY --from={pkg} /artifacts/usr /usr\n"
            df += f"COPY --from={pkg} /artifacts/usr/share/doc /usr/share/doc\n"
        
        df += "\nFROM cc as runtime\nUSER root\nARG RUNTIME_NAME\nARG RUNTIME_VER\nLABEL distroless.stack=\"${RUNTIME_NAME}\"\n"
        df += "COPY --from=runtime-setup /runtime-root/usr /usr\n"
        df += "USER 65532:65532\n"
        
        df += "\nFROM runtime as runtime-debug\nUSER root\nCOPY --from=builder /usr/bin/busybox /usr/bin/busybox\nRUN [\"/usr/bin/busybox\", \"--install\", \"-s\", \"/usr/bin\"]\nUSER 65532:65532\n"
        return df

class Visualizer:
    def __init__(self, stack_name):
        self.stack_name = stack_name

    def generate_mermaid(self, graph):
        mermaid = "graph TD\n"
        mermaid += "    %% Strict Dark Theme Styling\n"
        mermaid += "    classDef default fill:#0d1117,stroke:#30363d,color:#c9d1d9,stroke-width:2px;\n"
        mermaid += "    classDef core fill:#1f6feb,stroke:#58a6ff,color:#ffffff,font-weight:bold;\n"
        mermaid += "    classDef runtime fill:#238636,stroke:#3fb950,color:#ffffff,font-weight:bold;\n"
        mermaid += "    classDef dep fill:#161b22,stroke:#30363d,color:#8b949e,font-style:italic;\n\n"

        mermaid += "    subgraph Hierarchy\n"
        mermaid += "        S[static] --> B[base]\n"
        mermaid += "        B --> C[cc]\n"
        mermaid += "    end\n\n"
        
        for pkg, meta in graph.items():
            mermaid += f'    {pkg}["{pkg}"]\n'
            mermaid += f'    class {pkg} dep;\n'
            for dep in meta["depends"]:
                if dep in graph:
                    mermaid += f"    {pkg} --> {dep}\n"
        
        mermaid += f"\n    C --> R[runtime:{self.stack_name}]\n"
        mermaid += "    R --> RD[runtime-debug]\n"
        
        mermaid += "    class S,B,C core;\n"
        mermaid += "    class R,RD runtime;\n"
        
        return mermaid

def main():
    try:
        parser = argparse.ArgumentParser(description="Distroless Engine")
        parser.add_argument("--stack", required=True, help="Path to stack YAML")
        parser.add_argument("--graph", action="store_true", help="Generate Mermaid DAG")
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

            if args.graph:
                viz = Visualizer(stack_config['name'])
                mermaid = viz.generate_mermaid(resolver.graph)
                mermaid_path = f"docs/mermaid/{stack_config['name']}-distroless.mermaid"
                os.makedirs(os.path.dirname(mermaid_path), exist_ok=True)
                with open(mermaid_path, "w") as f:
                    f.write(mermaid)
                print(f"✅ Generated {mermaid_path}")
                
                # New: Automatically generate PNG image (optional in CI)
                if os.environ.get("RENDER_DIAGRAMS") == "true":
                    image_path = f"docs/images/{stack_config['name']}-distroless.png"
                    try:
                        import subprocess
                        print(f"🎨 Rendering {image_path}...")
                        subprocess.run(["npx", "-y", "@mermaid-js/mermaid-cli", "-i", mermaid_path, "-o", image_path, "-t", "dark", "-b", "transparent"], check=True, capture_output=True)
                        print(f"✅ Generated {image_path}")
                    except Exception as e:
                        print(f"⚠️ Could not generate PNG image: {e}")
                else:
                    print(f"ℹ️ Skipping PNG rendering (set RENDER_DIAGRAMS=true to enable)")
    except Exception as e:
        print(f"❌ FATAL ERROR in Engine: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
