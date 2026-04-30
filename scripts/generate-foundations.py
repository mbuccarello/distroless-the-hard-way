#!/usr/bin/env python3
"""
Sovereign Intelligence Script: Arch-to-Bake Sync
This script automates the translation protocol by fetching Arch Linux PKGBUILDs
and proposing the Docker Bake dependency graph.
"""

import urllib.request
import re
import sys

def fetch_pkgbuild(pkgname):
    """Fetches the raw PKGBUILD from Arch Linux GitLab."""
    url = f"https://gitlab.archlinux.org/archlinux/packaging/packages/{pkgname}/-/raw/main/PKGBUILD"
    print(f"// Fetching intelligence from: {url}", file=sys.stderr)
    try:
        with urllib.request.urlopen(url) as response:
            return response.read().decode('utf-8')
    except Exception as e:
        print(f"// Error fetching {pkgname}: {e}", file=sys.stderr)
        return None

def parse_depends(content):
    """Parses the depends=() array from a PKGBUILD."""
    match = re.search(r'depends=\((.*?)\)', content, re.DOTALL)
    if match:
        deps_raw = match.group(1).split()
        # Clean up quotes and versions (e.g. 'ncurses>=6.0')
        deps = [re.sub(r'[<>=].*', '', d.strip("'\"")) for d in deps_raw if d.strip()]
        return deps
    return []

def parse_configure_flags(content):
    """Attempts to extract common ./configure flags."""
    # Matches --flag or --flag=value
    flags = re.findall(r'--[a-z0-9-]+(?:=[a-z0-9/-]+)?', content)
    # Filter for interesting flags
    interesting = ["--enable-widec", "--with-shared", "--with-termlib", "--with-curses"]
    return [f for f in flags if any(i in f for i in interesting)]

def translate_to_bake(pkgname, deps, flags):
    """Outputs the HCL target definition."""
    print(f"\n// Intelligence gathered for {pkgname}")
    print(f"target \"{pkgname}\" {{")
    print(f"  inherits = [\"foundation-base\"]")
    
    # Filter system-level deps that we handle via the builder image
    filtered_deps = [d for d in deps if d not in ["glibc", "gcc-libs", "libgcc", "libstdc++"]]
    
    if filtered_deps:
        print("  contexts = {")
        for dep in filtered_deps:
            print(f"    deps = \"target:{dep}\"")
        print("  }")
    
    print("  args = {")
    print(f"    LIB_NAME = \"{pkgname}\"")
    if flags:
        print(f"    LIB_CONFIG = \"{' '.join(flags)}\"")
    print("  }")
    print("}")

def main():
    if len(sys.argv) < 2:
        print("Usage: generate-foundations.py <pkgname>")
        sys.exit(1)
    
    pkgname = sys.argv[1]
    content = fetch_pkgbuild(pkgname)
    if not content:
        sys.exit(1)

    deps = parse_depends(content)
    flags = parse_configure_flags(content)
    translate_to_bake(pkgname, deps, flags)

if __name__ == "__main__":
    main()
