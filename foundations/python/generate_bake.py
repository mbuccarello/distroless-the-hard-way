#!/usr/bin/env python3
import json
import urllib.request
import subprocess
import os
import tempfile
import sys
import re

# Targets required for Python distroless
CORE_TARGETS = ["ncurses", "readline", "openssl", "sqlite", "libffi", "bzip2", "xz", "zlib", "libxcrypt"]
ARCH_GITLAB_BASE = "https://gitlab.archlinux.org/archlinux/packaging/packages/{}/-/raw/main/PKGBUILD"

# Define library dependencies for Bake contexts
DEPENDENCIES = {
    "readline": ["ncurses"],
}


# Hardcoded ABI-aligned flags for critical libraries to prevent Segfault 139
CRITICAL_FLAGS = {
    "ncurses": "--with-shared --with-cxx-shared --enable-widec --without-debug --without-normal --with-termlib",
    "readline": "--with-curses",
    "libffi": "--disable-multi-os-directory",
    "libxcrypt": "--disable-obsolete-api"
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
                        info["sources"].append(line)
                        break

    main_url = info["sources"][0] if info["sources"] else None
    main_sha = info["sha512sums"][0] if info["sha512sums"] else None
    
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
                hcl += f'    {dep} = "target:{dep}"\n'
            hcl += '  }\n'
            
        hcl += f'  tags = ["${{REGISTRY}}/foundation-python-{pkg}:latest"]\n'
        hcl += f'}}\n\n'
    
    hcl += 'target "consolidated" {\n  dockerfile = "Dockerfile.consolidated"\n  context = "."\n  contexts = {\n'
    for pkg in graph.keys():
        hcl += f'    {pkg} = "target:{pkg}"\n'
    hcl += '  }\n  tags = ["${REGISTRY}/foundation-python-consolidated:latest"]\n}\n'

    with open("foundations/python/docker-bake.hcl", "w") as f:
        f.write(hcl)
    print("✅ foundations/python/docker-bake.hcl updated.")

if __name__ == "__main__":
    main()
