import os
import yaml
import json
import argparse
import urllib.request
import tempfile
import re

ARCH_GITLAB_BASE = "https://gitlab.archlinux.org/archlinux/packaging/packages/{}/-/raw/main/PKGBUILD"

from discovery import DiscoveryEngine

class MetadataManager:
    def __init__(self, cache_dir):
        self.cache_dir = cache_dir
        self.discovery = DiscoveryEngine(cache_dir)
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
            "gdbm": "https://ftp.gnu.org/pub/gnu/gdbm/gdbm-1.24.tar.gz",
            "icu": "https://github.com/unicode-org/icu/releases/download/release-75-1/icu4c-75_1-src.tgz",
            "brotli": "https://github.com/google/brotli/archive/refs/tags/v1.1.0.tar.gz",
            "c-ares": "https://github.com/c-ares/c-ares/releases/download/v1.34.2/c-ares-1.34.2.tar.gz",
            "nghttp2": "https://github.com/nghttp2/nghttp2/releases/download/v1.64.0/nghttp2-1.64.0.tar.gz",
            "krb5": "https://web.mit.edu/kerberos/dist/krb5/1.21/krb5-1.21.3.tar.gz",
            "libxml2": "https://download.gnome.org/sources/libxml2/2.12/libxml2-2.12.9.tar.xz",
            "oniguruma": "https://github.com/kkos/oniguruma/releases/download/v6.9.9/onig-6.9.9.tar.gz",
            "curl": "https://github.com/curl/curl/releases/download/curl-8_11_0/curl-8.11.0.tar.gz",
            "pcre2": "https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.44/pcre2-10.44.tar.gz"
        }

    def get_metadata(self, pkgname):
        res = {
            "url": self.hardcoded_sources.get(pkgname, "SKIP"),
            "sha": "SKIP",
            "version": "latest",
            "depends": []
        }
        
        meta = self.discovery.fetch_arch_metadata(pkgname)
        if meta:
            res["version"] = meta["version"]
            res["depends"] = meta["depends"]
            if res["url"] == "SKIP" and meta["sources"]:
                res["url"] = meta["sources"][0]
        
        return res

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
            visited.add(pkg)
            meta = self.manager.get_metadata(pkg)
            if not meta: continue
            self.graph[pkg] = meta
            for dep in meta['depends']:
                if dep in self.manager.hardcoded_sources:
                    stack.append(dep)
        self.graph = self.topological_sort()

    def topological_sort(self):
        sorted_nodes = []
        visited = set()
        temp_visited = set()

        def visit(node):
            if node in temp_visited:
                return # Ignore cycles for now or handle specifically
            if node in visited:
                return
            temp_visited.add(node)
            for dep in self.graph.get(node, {}).get('depends', []):
                if dep in self.graph:
                    visit(dep)
            temp_visited.remove(node)
            visited.add(node)
            sorted_nodes.append(node)

        for node in self.graph:
            visit(node)
        return {node: self.graph[node] for node in sorted_nodes}

class HCLGenerator:
    def __init__(self, registry=None, platform="linux/amd64"):
        self.registry = registry or os.environ.get("REGISTRY", "ghcr.io/mbuccarello")
        self.platform = platform

    def _header(self):
        hcl = f'variable "REGISTRY" {{\n  default = "{self.registry}"\n}}\n\n'
        hcl += f'variable "ATOMS_REGISTRY" {{\n  default = "{self.registry}/atoms"\n}}\n\n'
        return hcl

    def check_atom_exists(self, pkg, version):
        """Check if an atom already exists in the registry."""
        import subprocess
        
        # Bypass check if FORCE_BUILD is set
        if os.environ.get("FORCE_BUILD") == "true":
            print(f"  [CACHE] Force build enabled, skipping registry check for {pkg}:{version}")
            return False

        full_image = f"{self.registry}/atoms/{pkg}:{version}"
        try:
            # Use docker manifest inspect for a lightweight check
            subprocess.run(["docker", "manifest", "inspect", full_image], 
                           check=True, capture_output=True)
            print(f"  [CACHE] Found pre-compiled atom: {full_image}")
            return True
        except subprocess.CalledProcessError:
            print(f"  [CACHE] Atom not found in registry: {pkg}:{version} (will build from source)")
            return False

    def generate_foundation_hcl(self, graph=None):
        hcl = self._header()
        hcl += 'group "default" {\n  targets = ["static", "base", "cc"]\n}\n\n'
        
        # Builder target
        hcl += 'target "builder" {\n  dockerfile = "foundations/builder.Dockerfile"\n  target = "builder"\n  context = "."\n'
        hcl += f'  platforms = ["{self.platform}"]\n}}\n\n'
        
        # Static and Base
        hcl += 'target "static" {\n  dockerfile = "foundations/static.Dockerfile"\n  target = "static"\n  context = "."\n  contexts = { builder = "target:builder" }\n'
        hcl += '  tags = ["${REGISTRY}/static:latest"]\n}\n\n'
        
        hcl += 'target "base" {\n  dockerfile = "foundations/base.Dockerfile"\n  target = "base"\n  context = "."\n  contexts = { builder = "target:builder", static = "target:static" }\n'
        hcl += '  tags = ["${REGISTRY}/base:latest"]\n}\n\n'

        # Library targets for foundation
        if graph:
            for pkg, meta in graph.items():
                hcl += f'target "{pkg}" {{\n'
                hcl += '  dockerfile = "foundations/runtime.Dockerfile"\n'
                hcl += f'  target = "{pkg}"\n'
                hcl += '  context = "."\n'
                hcl += f'  platforms = ["{self.platform}"]\n'
                hcl += '  args = {\n'
                hcl += f'    LIB_NAME = "{pkg}"\n'
                hcl += f'    LIB_URL = "{meta["url"]}"\n'
                
                lib_config = ""
                if pkg == "zlib": lib_config = "--shared"
                if pkg == "openssl": lib_config = "shared zlib"
                if pkg == "ncurses": lib_config = "--with-shared --enable-widec --enable-pc-files --with-termlib"
                if pkg == "readline": lib_config = "--with-curses"
                if pkg == "libxcrypt": lib_config = "--disable-werror --enable-hashes=all --enable-obsolete-api=no"
                if pkg == "icu": lib_config = "--enable-static --enable-shared --disable-tests --disable-samples --disable-extras --disable-icuio --disable-layoutex --disable-tools"
                if pkg == "brotli": lib_config = "" # CMake usually, but let's see
                if pkg == "c-ares": lib_config = ""
                if pkg == "nghttp2": lib_config = "--enable-lib-only"
                if pkg == "krb5": lib_config = "--with-crypto-impl=openssl"
                if lib_config: hcl += f'    LIB_CONFIG = "{lib_config}"\n'
                
                lib_subdir = ""
                if pkg == "icu": lib_subdir = "source"
                if pkg == "krb5": lib_subdir = "src"
                if lib_subdir: hcl += f'    LIB_SUBDIR = "{lib_subdir}"\n'
                
                hcl += '  }\n'
                hcl += '  contexts = {\n    builder = "target:builder"\n'
                for dep in meta['depends']:
                    if dep in graph:
                        hcl += f'    {dep} = "target:{dep}"\n'
                hcl += '  }\n'
                hcl += '}\n\n'

        # Common CC (Base for all runtimes)
        hcl += 'target "cc" {\n  dockerfile = "foundations/cc.Dockerfile"\n  target = "cc"\n  context = "."\n'
        hcl += '  contexts = {\n    builder = "target:builder"\n    base = "target:base"\n'
        if graph:
            for pkg in graph.keys():
                hcl += f'    {pkg} = "target:{pkg}"\n'
        hcl += '  }\n'
        hcl += '  tags = ["${REGISTRY}/cc:latest"]\n}\n\n'
        
        return hcl

    def generate_runtime_hcl(self, stack_config, graph):
        hcl = self._header()
        name = stack_config["name"]
        runtime = stack_config.get("runtime", {})
        stack_type = runtime.get("type") or stack_config.get("type", "source_build")
        has_source = stack_type == "source_build"
        
        hcl += 'group "default" {\n  targets = ["runtime", "runtime-debug"]\n}\n\n'
        
        # Reuse existing foundations as external contexts
        hcl += 'target "foundations" {\n  dockerfile = "foundations/builder.Dockerfile"\n  context = "."\n}\n\n'
        
        # Library targets for THIS runtime
        if stack_type == "source_build":
            for pkg, meta in graph.items():
                version = meta.get("version", "latest")
                atom_exists = self.check_atom_exists(pkg, version)
                
                # We still generate the target so it's visible in the HCL, 
                # but we'll use it only if it doesn't exist remotely
                hcl += f'target "{pkg}" {{\n'
                hcl += '  dockerfile = "foundations/runtime.Dockerfile"\n'
                hcl += f'  target = "{pkg}"\n'
                hcl += '  context = "."\n'
                hcl += f'  platforms = ["{self.platform}"]\n'
                hcl += f'  tags = ["${{ATOMS_REGISTRY}}/{pkg}:{version}"]\n'
                hcl += '  args = {\n'
                hcl += f'    LIB_NAME = "{pkg}"\n'
                hcl += f'    LIB_URL = "{meta["url"]}"\n'
                
                lib_config = ""
                if pkg == "zlib": lib_config = "--shared"
                if pkg == "openssl": lib_config = "shared zlib"
                if pkg == "ncurses": lib_config = "--with-shared --enable-widec --enable-pc-files --with-termlib"
                if pkg == "readline": lib_config = "--with-curses"
                if pkg == "libxcrypt": lib_config = "--disable-werror --enable-hashes=all --enable-obsolete-api=no"
                if pkg == "icu": lib_config = "--enable-static --enable-shared --disable-tests --disable-samples --disable-extras --disable-icuio --disable-layoutex --disable-tools"
                if pkg == "nghttp2": lib_config = "--enable-lib-only"
                if pkg == "krb5": lib_config = "--with-crypto-impl=openssl --with-system-verto=no --disable-rpath"
                if pkg == "libxml2": lib_config = "--without-python --without-icu"
                if pkg == "curl": lib_config = "--with-openssl=/opt/distroless --with-zlib=/opt/distroless --with-nghttp2=/opt/distroless --with-ca-bundle=/etc/ssl/certs/ca-certificates.crt"
                if pkg == "pcre2": lib_config = "--enable-jit --enable-unicode"
                if pkg == "oniguruma": lib_config = "--enable-shared"
                if lib_config: hcl += f'    LIB_CONFIG = "{lib_config}"\n'

                lib_subdir = ""
                if pkg == "icu": lib_subdir = "source"
                if pkg == "krb5": lib_subdir = "src"
                if lib_subdir: hcl += f'    LIB_SUBDIR = "{lib_subdir}"\n'

                hcl += '  }\n'
                hcl += '  contexts = {\n    builder = "target:foundations"\n'
                for dep in meta['depends']:
                    if dep in graph:
                        dep_meta = graph[dep]
                        dep_version = dep_meta.get("version", "latest")
                        if self.check_atom_exists(dep, dep_version):
                            hcl += f'    {dep} = "docker-image://${{ATOMS_REGISTRY}}/{dep}:{dep_version}"\n'
                        else:
                            hcl += f'    {dep} = "target:{dep}"\n'
                hcl += '  }\n}\n\n'

            # CC target (Specialized for this runtime)
            hcl += f'target "cc-{name}" {{\n'
            hcl += f'  dockerfile = "foundations/cc-{name}.Dockerfile"\n  target = "cc"\n  context = "."\n'
            hcl += '  contexts = {\n'
            hcl += '    builder = "target:foundations"\n'
            hcl += '    base = "docker-image://${REGISTRY}/base:latest"\n'
            for pkg, meta in graph.items():
                version = meta.get("version", "latest")
                if self.check_atom_exists(pkg, version):
                    hcl += f'    {pkg} = "docker-image://${{ATOMS_REGISTRY}}/{pkg}:{version}"\n'
                else:
                    hcl += f'    {pkg} = "target:{pkg}"\n'
            hcl += '  }\n}\n\n'

        # Final Runtime
        hcl += 'target "runtime" {\n'
        hcl += '  dockerfile = "foundations/runtime.Dockerfile"\n  target = "runtime"\n  context = "."\n'
        hcl += '  args = {\n'
        hcl += f'    RUNTIME_NAME = "{name}"\n'
        hcl += f'    RUNTIME_VER = "{stack_config["version"]}"\n'
        if stack_type == "binary_injection":
            hcl += f'    RUNTIME_URL = "{runtime["binary_url"]}"\n'
        hcl += '  }\n'
        hcl += '  contexts = {\n'
        if stack_type == "source_build":
            hcl += f'    cc = "target:cc-{name}"\n'
        else:
            hcl += '    cc = "docker-image://${REGISTRY}/cc:latest"\n'
        hcl += '    builder = "target:foundations"\n'
        if stack_type == "source_build":
            for pkg in graph.keys():
                hcl += f'    {pkg} = "target:{pkg}"\n'
        hcl += '  }\n'
        hcl += f'  tags = ["${{REGISTRY}}/{name}-distroless:latest"]\n}}\n\n'

        hcl += 'target "runtime-debug" {\n  inherits = ["runtime"]\n  target = "runtime-debug"\n'
        hcl += f'  tags = ["${{REGISTRY}}/{name}-distroless:debug"]\n}}\n'
        
        return hcl

    def generate_cc_dockerfile(self, graph):
        df = "# syntax=docker/dockerfile:1.4\nFROM base AS cc\nUSER root\n"
        df += "RUN mkdir -p /usr/lib64\n"
        df += "COPY --from=builder /usr/lib64/libgcc_s.so.1 /usr/lib64/\n"
        df += "COPY --from=builder /usr/lib64/libstdc++.so.6 /usr/lib64/\n"
        df += "RUN ln -sf /usr/lib64/libgcc_s.so.1 /usr/lib/libgcc_s.so.1 && \\\n"
        df += "    ln -sf /usr/lib64/libstdc++.so.6 /usr/lib/libstdc++.so.6\n"
        for pkg in graph.keys():
            df += f"COPY --from={pkg} /artifacts/usr /usr\n"
        df += "LABEL distroless.layer=\"cc\"\nUSER 65532:65532\n"
        return df

    def generate_runtime_dockerfile(self, graph, stack_config=None):
        df = ""
        runtime = stack_config.get("runtime", {}) if stack_config else {}
        stack_type = runtime.get("type") or stack_config.get("type", "source_build") if stack_config else "source_build"
        for pkg, meta in graph.items():
            df += f"\nFROM builder AS {pkg}\n"
            df += f"ARG LIB_NAME={pkg}\nARG LIB_URL\nARG LIB_CONFIG\nARG LIB_SUBDIR=.\n"
            for dep in meta['depends']:
                if dep in graph: df += f"COPY --from={dep} /artifacts/usr /opt/distroless\n"
            df += "WORKDIR /build\nRUN set -ex && if [ -n \"$LIB_URL\" ] && [ \"$LIB_URL\" != \"SKIP\" ]; then \\\n"
            if pkg == "icu":
                df += "    dnf install -y libicu-devel && \\\n"
                df += "    mkdir -p /artifacts/usr/lib64 /artifacts/usr/include && \\\n"
                df += "    cp -rv /usr/lib64/libicu* /artifacts/usr/lib64/ && \\\n"
                df += "    cp -rv /usr/include/unicode /artifacts/usr/include/ && \\\n"
                df += "    echo \"ICU installed via dnf\"; \\\n"
            else:
                df += "    curl -L \"$LIB_URL\" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src/$LIB_SUBDIR && \\\n"
                df += "    mkdir -p /opt/distroless && \\\n"
                df += "    export CPPFLAGS=\"-I/opt/distroless/include\" && \\\n"
                df += "    if [ \"$LIB_NAME\" = \"icu\" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS=\"$CXXFLAGS -fno-var-tracking-assignments -g0\"; fi && \\\n"
                df += "    export LDFLAGS=\"-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib\" && \\\n"
                df += "    export PKG_CONFIG_PATH=\"/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig\" && \\\n"
                df += "    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless || true && \\\n"
                df += "    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all || true && \\\n"
                df += "    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; "
                df += "elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \\\n"
                df += "    if [ \"$LIB_NAME\" = \"icu\" ]; then make -j1 && make DESTDIR=/artifacts install; elif [ \"$LIB_NAME\" = \"bzip2\" ]; then make -j2 PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j2 && make DESTDIR=/artifacts install; fi; \\\n"
            df += "    fi && mkdir -p /artifacts/usr\n"

        if not stack_config:
            return df

        # Runtime Setup Stage: Extracting or Building language binaries
        df += "\nFROM builder AS runtime-setup\nUSER root\nRUN mkdir -p /runtime-root/usr /runtime-root/etc /runtime-root/var /opt/distroless\n"
        for pkg in graph.keys():
            df += f"COPY --from={pkg} /artifacts/usr /opt/distroless\n"
        if stack_type == "binary_injection":
            runtime_name = stack_config["name"] if stack_config else ""
            df += f"ARG RUNTIME_NAME={runtime_name}\nARG RUNTIME_URL\nRUN set -ex && mkdir -p /tmp/extract && \\\n"
            df += "    if [ \"$RUNTIME_URL\" = \"DNF\" ]; then \\\n"
            df += "      dnf clean all && dnf install -y --setopt=install_weak_deps=False $RUNTIME_NAME $RUNTIME_NAME-fpm $RUNTIME_NAME-mysqlnd $RUNTIME_NAME-opcache $RUNTIME_NAME-xml $RUNTIME_NAME-mbstring $RUNTIME_NAME-gd $RUNTIME_NAME-curl || dnf install -y $RUNTIME_NAME && \\\n"
            df += "      mkdir -p /runtime-root/usr/bin /runtime-root/usr/sbin /runtime-root/usr/lib64 /runtime-root/etc && \\\n"
            df += "      cp -rv /usr/bin/${RUNTIME_NAME}* /runtime-root/usr/bin/ || true && \\\n"
            df += "      cp -rv /usr/sbin/${RUNTIME_NAME}* /runtime-root/usr/sbin/ || true && \\\n"
            df += "      cp -rv /usr/lib64/lib${RUNTIME_NAME}* /runtime-root/usr/lib64/ || true && \\\n"
            df += "      cp -rv /etc/${RUNTIME_NAME}* /runtime-root/etc/ || true && \\\n"
            df += "      echo \"Runtime installed via dnf\"; \\\n"
            df += "    else \\\n"
            df += "      curl -L \"$RUNTIME_URL\" -o /tmp/runtime.tar.gz && \\\n"
            df += "      mkdir -p /tmp/extract && tar -xf /tmp/runtime.tar.gz -C /tmp/extract && \\\n"
            df += "      if [ \"$RUNTIME_NAME\" = \"dotnet\" ]; then \\\n"
            df += "        mkdir -p /runtime-root/usr/share/dotnet && cp -rv /tmp/extract/* /runtime-root/usr/share/dotnet/ && \\\n"
            df += "        mkdir -p /runtime-root/usr/bin && ln -sf /usr/share/dotnet/dotnet /runtime-root/usr/bin/dotnet; \\\n"
            df += "      else \\\n"
            df += "        BIN_DIR=$(find /tmp/extract -name bin -type d | head -n 1) && \\\n"
            df += "        if [ -n \"$BIN_DIR\" ]; then \\\n"
            df += "          SRC_DIR=$(dirname \"$BIN_DIR\"); \\\n"
            df += "          cp -rv \"$SRC_DIR\"/* /runtime-root/usr/; \\\n"
            df += "        else \\\n"
            df += "          cp -rv /tmp/extract/* /runtime-root/usr/; \\\n"
            df += "        fi; \\\n"
            df += "      fi; \\\n"
            df += "    fi\n"
        else:
            # Source build for runtime
            source_url = runtime.get("source_url", "")
            build_flags = " ".join(runtime.get("build_flags", []))
            df += f"RUN set -ex && curl -L \"{source_url}\" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src && \\\n"
            df += "    export CPPFLAGS=\"-I/opt/distroless/include\" && \\\n"
            df += "    export LDFLAGS=\"-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib\" && \\\n"
            df += "    export PKG_CONFIG_PATH=\"/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig\" && \\\n"
            # Special handling for Perl's Configure which is not autoconf
            df += f"    if [ -f ./Configure ] && grep -q \"Perl\" ./Configure; then \\\n"
            df += f"        ./Configure {build_flags} -Dlocincpth=\"/opt/distroless/include\" -Dloclibpth=\"/opt/distroless/lib /opt/distroless/lib64\"; \\\n"
            df += f"    elif [ -f ./configure ]; then ./configure --prefix=/usr {build_flags}; "
            df += f"elif [ -f ./Configure ]; then ./Configure {build_flags}; "
            df += f"elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr {build_flags} .; fi && \\\n"
            df += "    export CXXFLAGS=\"$CXXFLAGS -fno-var-tracking-assignments -g0 -O1\" && \\\n"
            df += "    export CFLAGS=\"$CFLAGS -g0 -O1\" && \\\n"
            df += "    make -j1 && make DESTDIR=/runtime-root install\n"
            
        df += "\nFROM cc AS runtime\nUSER root\nARG RUNTIME_NAME\nARG RUNTIME_VER\nLABEL distroless.stack=\"${RUNTIME_NAME}\"\n"
        if stack_config and stack_config["name"] == "dotnet":
            df += "ENV DOTNET_ROOT=/usr/share/dotnet\n"
            df += "ENV PATH=\"${PATH}:/usr/share/dotnet\"\n"
        df += "COPY --from=runtime-setup /runtime-root/usr/ /usr/\n"
        # For source builds, we might need some extra copies if the layout is different
        if stack_type == "source_build":
            df += "COPY --from=runtime-setup /runtime-root/etc/ /etc/\n"
            df += "COPY --from=runtime-setup /runtime-root/var/ /var/\n"
        df += "USER 65532:65532\n"
        
        df += "\nFROM runtime AS runtime-debug\nUSER root\nCOPY --from=builder /usr/bin/busybox /usr/bin/busybox\n"
        df += "RUN [\"/usr/bin/busybox\", \"--install\", \"-s\", \"/usr/bin\"]\nUSER 65532:65532\n"
        return df

def main():
    parser = argparse.ArgumentParser(description="Distroless Build Engine")
    parser.add_argument("--mode", choices=["foundation", "runtime"], required=True)
    parser.add_argument("--stack", help="Path to stack YAML config (required for runtime mode)")
    parser.add_argument("--force-build", action="store_true", help="Skip registry check and build everything from source")
    args = parser.parse_args()

    if args.force_build:
        os.environ["FORCE_BUILD"] = "true"

    generator = HCLGenerator()
    
    if args.mode == "foundation":
        print("🚀 Resolving core dependencies for foundation CC...")
        with tempfile.TemporaryDirectory() as tmpdir:
            manager = MetadataManager(tmpdir)
            resolver = DAGResolver(manager)
            # Core libraries for CC foundation
            resolver.resolve(["zlib", "openssl", "libxcrypt"])
            
            hcl = generator.generate_foundation_hcl(resolver.graph)
            with open("foundations/foundations.hcl", "w") as f: f.write(hcl)
            
            # We also need the library builders in a Dockerfile for foundation CC
            df = generator.generate_runtime_dockerfile(resolver.graph)
            with open("foundations/runtime.Dockerfile", "w") as f: f.write(df)
            
            # Generate the foundation CC Dockerfile (base core libs)
            cc_df = generator.generate_cc_dockerfile(resolver.graph)
            with open("foundations/cc.Dockerfile", "w") as f: f.write(cc_df)
            
        print("✅ Generated foundations/foundations.hcl and foundations/runtime.Dockerfile")
    
    elif args.mode == "runtime":
        if not args.stack:
            print("❌ Error: --stack is required for runtime mode")
            return
        with open(args.stack, 'r') as f:
            stack_config = yaml.safe_load(f)
        
        print(f"🚀 Resolving dependencies for {stack_config['name']}...")
        with tempfile.TemporaryDirectory() as tmpdir:
            manager = MetadataManager(tmpdir)
            resolver = DAGResolver(manager)
            deps = stack_config.get('dependencies', [])
            initial_deps = [d['name'] for d in deps]
            # Always ensure core foundation libraries are present for the CC layer
            for core_dep in ["zlib", "openssl", "libxcrypt"]:
                if core_dep not in initial_deps:
                    initial_deps.append(core_dep)
            resolver.resolve(initial_deps)
            
            hcl = generator.generate_runtime_hcl(stack_config, resolver.graph)
            with open(f"foundations/{stack_config['name']}.hcl", "w") as f: f.write(hcl)
            
            df = generator.generate_runtime_dockerfile(resolver.graph, stack_config)
            with open("foundations/runtime.Dockerfile", "w") as f: f.write(df)
            
            # Generate stack-specific CC Dockerfile
            cc_df = generator.generate_cc_dockerfile(resolver.graph)
            with open(f"foundations/cc-{stack_config['name']}.Dockerfile", "w") as f: f.write(cc_df)
            
            print(f"✅ Generated foundations/{stack_config['name']}.hcl, foundations/cc-{stack_config['name']}.Dockerfile and foundations/runtime.Dockerfile")

if __name__ == "__main__":
    main()
