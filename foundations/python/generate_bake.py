#!/usr/bin/env python3
import json
import urllib.request
import subprocess
import os
import tempfile
import sys
import re

# Targets required for Python distroless
CORE_TARGETS = ["ncurses", "readline", "openssl", "sqlite", "libffi", "bzip2", "xz", "zlib", "libxcrypt", "expat", "gdbm", "python"]
ARCH_GITLAB_BASE = "https://gitlab.archlinux.org/archlinux/packaging/packages/{}/-/raw/main/PKGBUILD"

# Define library dependencies for Bake contexts
DEPENDENCIES = {
    "readline": ["ncurses"],
    "openssl": ["zlib"],
    "sqlite": ["zlib", "readline", "ncurses"],
    "python": ["ncurses", "readline", "openssl", "sqlite", "libffi", "bzip2", "xz", "zlib", "libxcrypt", "expat", "gdbm"]
}


# Hardcoded ABI-aligned flags for critical libraries to prevent Segfault 139
CRITICAL_FLAGS = {
    "ncurses": "--with-shared --with-cxx-shared --enable-widec --without-debug --without-normal --with-termlib",
    "readline": "--with-curses",
    "libffi": "--disable-multi-os-directory",
    "libxcrypt": "--disable-obsolete-api --disable-werror",
    "python": "--enable-shared --with-system-ffi --with-system-expat --enable-optimizations --with-lto --enable-loadable-sqlite-extensions --without-ensurepip"
}

# Hardcoded sources for packages that are tricky to parse
HARDCODED_SOURCES = {
    "expat": "https://github.com/libexpat/libexpat/releases/download/R_2_6_2/expat-2.6.2.tar.bz2",
    "gdbm": "https://ftp.gnu.org/gnu/gdbm/gdbm-1.23.tar.gz"
}

# Some packages require specific make flags (like Arch does for readline)
CRITICAL_MAKE = {
    "readline": 'SHLIB_LIBS=\\"-lncursesw -ltinfo\\"'
}

def fetch_pkgbuild(pkgname, dest_dir):
    url = ARCH_GITLAB_BASE.format(pkgname)
    dest = os.path.join(dest_dir, "PKGBUILD")
    try:
        urllib.request.urlretrieve(url, dest)
        return True
    except Exception as e:
        return False

def get_metadata(pkgname, pkg_dir):
    cmd = [
        "docker", "run", "--rm", "--platform", "linux/amd64",
        "-v", f"{pkg_dir}:/pkg",
        "archlinux",
        "bash", "-c",
        "useradd -m builduser && chown -R builduser:builduser /pkg && su builduser -c 'cd /pkg && makepkg --printsrcinfo'"
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    srcinfo = result.stdout
    
    info = {"sources": [], "sha512sums": []}
    
    if srcinfo:
        for line in srcinfo.splitlines():
            line = line.strip()
            if line.startswith("source ="):
                src = line.split("=", 1)[1].strip()
                if "::" in src: src = src.split("::")[1]
                info["sources"].append(src)
            elif line.startswith("sha512sums ="):
                info["sha512sums"].append(line.split("=", 1)[1].strip())
    
    if not info["sources"]:
        with open(os.path.join(pkg_dir, "PKGBUILD"), "r") as f:
            content = f.read()
            # Simple variable expansion for url, pkgname, pkgver, pkgbase
            vars = {}
            for v in ["url", "pkgname", "pkgver", "pkgbase"]:
                match = re.search(fr"^{v}=(.*)$", content, re.MULTILINE)
                if match: vars[v] = match.group(1).strip("\"").strip("'")

            src_match = re.search(r"source=\((.*?)\)", content, re.DOTALL)
            if src_match:
                for line in src_match.group(1).split():
                    line = line.strip("\"").strip("'")
                    # Expand variables in the source line
                    for k, v in vars.items():
                        line = line.replace(f"${{{k}}}", v).replace(f"${k}", v)
                    
                    # Clean up Bash brace expansion like {,.asc}
                    if "{" in line: line = line.split("{")[0]
                    # Strip quotes after splitting braces
                    line = line.strip("\"").strip("'")
                    # Clean up double slashes (except after http:)
                    line = re.sub(r"(?<!:)/{2,}", "/", line)
                    
                    if "::" in line: line = line.split("::")[1]
                    if line.startswith("http") or line.startswith("git+"):
                        if "{" in line or "$" in line:
                            # Try to resolve common variables if still present
                            line = line.replace("${pkgname}", pkgname).replace("$pkgname", pkgname)
                            line = line.replace("${pkgver}", "latest").replace("$pkgver", "latest") # Rough fallback
                        info["sources"].append(line)
                        break

    main_url = HARDCODED_SOURCES.get(pkgname, info["sources"][0] if info["sources"] else None)
    main_sha = "SKIP" if pkgname in HARDCODED_SOURCES else (info["sha512sums"][0] if info["sha512sums"] else None)
    
    return {
        "url": main_url, 
        "sha": main_sha, 
        "flags": CRITICAL_FLAGS.get(pkgname, ""),
        "make_extra": CRITICAL_MAKE.get(pkgname, "")
    }

def main():
    print("🚀 Starting Sovereign Distroless Automation Engine (V7)...")
    graph = {}
    
    for pkg in CORE_TARGETS:
        print(f"📦 Processing {pkg}...")
        with tempfile.TemporaryDirectory() as tmpdir:
            if not fetch_pkgbuild(pkg, tmpdir): continue
            data = get_metadata(pkg, tmpdir)
            graph[pkg] = data

    hcl = 'group "default" {\n  targets = [' + ", ".join(f'"{k}"' for k in graph.keys()) + ', "consolidated"]\n}\n\n'
    hcl += 'variable "REGISTRY" { default = "ghcr.io/mbuccarello" }\n\n'
    hcl += 'target "foundation-base" {\n  dockerfile = "Dockerfile"\n  context = "."\n}\n\n'

    for pkg, data in graph.items():
        hcl += f'target "{pkg}" {{\n'
        hcl += f'  inherits = ["foundation-base"]\n'
        hcl += f'  args = {{\n'
        hcl += f'    LIB_NAME = "{pkg}"\n'
        if data["url"]: hcl += f'    LIB_URL = "{data["url"]}"\n'
        if data["sha"] and data["sha"] != "SKIP": hcl += f'    LIB_SHA = "{data["sha"]}"\n'
        if data["flags"]: hcl += f'    LIB_CONFIG = "{data["flags"]}"\n'
        if data["make_extra"]: hcl += f'    MAKE_EXTRA = "{data["make_extra"]}"\n'
        hcl += f'  }}\n'
        
        if pkg in DEPENDENCIES:
            hcl += '  contexts = {\n'
            for dep in DEPENDENCIES[pkg]:
                hcl += f'    deps = "target:{dep}"\n'
                hcl += f'    {dep} = "target:{dep}"\n'
            hcl += '  }\n'
            
        hcl += f'  tags = ["${{REGISTRY}}/foundation-python-{pkg}:latest"]\n'
        hcl += f'}}\n\n'
    
    hcl += 'target "consolidated" {\n  dockerfile = "Dockerfile.consolidated"\n  context = "."\n  contexts = {\n'
    for pkg in graph.keys():
        if pkg != "python":
            hcl += f'    {pkg} = "target:{pkg}"\n'
    hcl += '  }\n  tags = ["${REGISTRY}/foundation-python-consolidated:latest"]\n}\n\n'

    hcl += 'target "runtime" {\n  dockerfile = "Dockerfile.runtime"\n  context = "."\n  contexts = {\n'
    hcl += '    python = "target:python"\n'
    hcl += '    consolidated = "target:consolidated"\n'
    hcl += '  }\n  tags = ["${REGISTRY}/python-distroless:3.12-sovereign"]\n}\n'

    with open("foundations/python/docker-bake.hcl", "w") as f:
        f.write(hcl)
    
    # Generate Dockerfile.consolidated
    df_consolidated = "# syntax=docker/dockerfile:1.4\nFROM scratch\n"
    for pkg in graph.keys():
        if pkg != "python":
            df_consolidated += f"COPY --from={pkg} /usr /usr\n"
    
    with open("foundations/python/Dockerfile.consolidated", "w") as f:
        f.write(df_consolidated)
    
    print("✅ foundations/python/docker-bake.hcl updated.")
    print("✅ foundations/python/Dockerfile.consolidated updated.")

if __name__ == "__main__":
    main()
