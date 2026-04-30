#!/usr/bin/env python3
import json
import urllib.request
import subprocess
import os
import tempfile
import sys

# Targets required for Python distroless
CORE_TARGETS = ["ncurses", "readline", "openssl", "sqlite", "libffi", "bzip2", "xz", "zlib", "libxcrypt"]
ARCH_GITLAB_BASE = "https://gitlab.archlinux.org/archlinux/packaging/packages/{}/-/raw/main/PKGBUILD"

def fetch_pkgbuild(pkgname, dest_dir):
    url = ARCH_GITLAB_BASE.format(pkgname)
    dest = os.path.join(dest_dir, "PKGBUILD")
    try:
        urllib.request.urlretrieve(url, dest)
        return True
    except Exception as e:
        return False

def get_srcinfo(pkg_dir):
    cmd = [
        "docker", "run", "--rm", "--platform", "linux/amd64",
        "-v", f"{pkg_dir}:/pkg",
        "archlinux",
        "bash", "-c",
        "useradd -m builduser && chown -R builduser:builduser /pkg && su builduser -c 'cd /pkg && makepkg --printsrcinfo'"
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.stdout if result.returncode == 0 else None

def parse_srcinfo(srcinfo_text):
    info = {"sources": [], "sha512sums": [], "pkgver": ""}
    for line in srcinfo_text.splitlines():
        line = line.strip()
        if line.startswith("pkgver ="):
            info["pkgver"] = line.split("=", 1)[1].strip()
        elif line.startswith("source ="):
            src = line.split("=", 1)[1].strip()
            if "::" in src: src = src.split("::")[1]
            info["sources"].append(src)
        elif line.startswith("sha512sums ="):
            info["sha512sums"].append(line.split("=", 1)[1].strip())
        elif line.startswith("b2sums ="): # Fallback to b2sums
            if not info["sha512sums"]:
                 info["sha512sums"].append(line.split("=", 1)[1].strip())
    
    main_url = None
    main_sha = None
    
    for i, src in enumerate(info["sources"]):
        if src.startswith("http") or src.startswith("git+"):
            main_url = src
            if i < len(info["sha512sums"]) and info["sha512sums"][i] != "SKIP":
                main_sha = info["sha512sums"][i]
            break

    return {"url": main_url, "sha": main_sha}

def intercept_flags(pkgname, pkg_dir):
    cmd = [
        "docker", "run", "--rm", "--platform", "linux/amd64",
        "-v", f"{pkg_dir}:/pkg",
        "archlinux",
        "bash", "-c",
        """cd /pkg && pacman -Sy --noconfirm base-devel > /dev/null 2>&1 && \
           grep -oP './configure\s+[^&|;]*' PKGBUILD | head -n 1 || echo ""
        """
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.stdout.strip()

def main():
    print("🚀 Starting Sovereign Distroless Automation Engine...")
    graph = {}
    
    for pkg in CORE_TARGETS:
        print(f"📦 Processing {pkg}...")
        with tempfile.TemporaryDirectory() as tmpdir:
            if not fetch_pkgbuild(pkg, tmpdir): continue
            srcinfo = get_srcinfo(tmpdir)
            if not srcinfo: continue
            data = parse_srcinfo(srcinfo)
            data["flags"] = intercept_flags(pkg, tmpdir)
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
        if data["flags"]:
            flags = data["flags"].replace("./configure", "").replace("--prefix=/usr", "").replace("--libdir=/usr/lib", "").replace("--libdir=/usr/lib64", "").strip()
            hcl += f'    LIB_CONFIG = "{flags}"\n'
        hcl += f'  }}\n'
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
