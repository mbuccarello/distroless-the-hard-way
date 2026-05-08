import re
import os
import urllib.request
import json
import tempfile

ARCH_GITLAB_BASE = "https://gitlab.archlinux.org/archlinux/packaging/packages/{}/-/raw/main/PKGBUILD"

class DiscoveryEngine:
    def __init__(self, cache_dir=".cache"):
        self.cache_dir = cache_dir
        if not os.path.exists(cache_dir):
            os.makedirs(cache_dir)
        # Mapping between pkg-config names and our internal names
        self.common_mapping = {
            "openssl": "openssl",
            "libxml-2.0": "libxml2",
            "sqlite3": "sqlite",
            "zlib": "zlib",
            "libcurl": "curl",
            "libpcre2-8": "pcre2",
            "oniguruma": "oniguruma"
        }

    def fetch_arch_metadata(self, pkgname):
        """Fetch and parse PKGBUILD from Arch Linux."""
        url = ARCH_GITLAB_BASE.format(pkgname)
        try:
            with urllib.request.urlopen(url) as response:
                content = response.read().decode('utf-8')
            
            metadata = {"depends": [], "sources": [], "version": "latest", "pkgname": pkgname}
            
            # Extract version
            version_match = re.search(r'pkgver=([^\s]+)', content)
            if version_match:
                metadata["version"] = version_match.group(1).replace('"', '').replace("'", "")

            # Extract dependencies
            depends_match = re.search(r'depends=\((.*?)\)', content, re.DOTALL)
            if depends_match:
                deps_str = depends_match.group(1).replace('"', '').replace("'", "")
                metadata["depends"] = [d.split('>')[0].split('<')[0].split('=')[0].strip() for d in deps_str.split() if d.strip()]
            
            # Extract sources
            sources_match = re.search(r'source=\((.*?)\)', content, re.DOTALL)
            if sources_match:
                src_str = sources_match.group(1).replace('"', '').replace("'", "")
                for s in src_str.split():
                    s = s.strip()
                    if s.startswith("http") and any(s.endswith(ext) for ext in [".tar.gz", ".tar.xz", ".tar.bz2", ".tar.zst"]):
                        # Cleanup Arch variables
                        s = s.replace("$pkgver", metadata["version"]).replace("${pkgver}", metadata["version"])
                        s = s.replace("$pkgname", pkgname).replace("${pkgname}", pkgname)
                        metadata["sources"].append(s)
            
            return metadata
        except Exception as e:
            print(f"  [DISCOVERY] Failed to fetch Arch metadata for {pkgname}: {e}")
            return None

    def discover_dependencies(self, source_dir):
        """Analyze a source directory to find dependencies via pkg-config, CMake, and Meson."""
        discovered_pc = set()
        
        for root, dirs, files in os.walk(source_dir):
            for file in files:
                if file in ["configure", "configure.ac", "Makefile.am", "CMakeLists.txt", "meson.build"]:
                    path = os.path.join(root, file)
                    with open(path, "r", errors="ignore") as f:
                        content = f.read()
                        # pkg-config checks (Autotools/CMake)
                        pc_matches = re.findall(r'PKG_CHECK_MODULES\([A-Z0-9_]+,\s*\[?([a-zA-Z0-9_.-]+)', content)
                        discovered_pc.update(pc_matches)
                        
                        # CMake find_package(NAME REQUIRED)
                        cmake_matches = re.findall(r'find_package\(([a-zA-Z0-9_]+)', content)
                        discovered_pc.update([c.lower() for c in cmake_matches])
                        
                        # Meson dependency('name')
                        meson_matches = re.findall(r"dependency\(['\"]([a-zA-Z0-9_.-]+)['\"]", content)
                        discovered_pc.update(meson_matches)
                        
                        # Generic library checks like -lssl
                        lib_matches = re.findall(r'-l([a-zA-Z0-9_-]+)', content)
                        # Filter out common false positives or system libs we don't treat as atoms
                        filtered_libs = [l for l in lib_matches if l not in ["m", "pthread", "dl", "rt"]]
                        discovered_pc.update(filtered_libs)
                        
        mapped_deps = set()
        # Common system names to our internal atom names
        internal_mapping = {
            "libssl": "openssl",
            "libcrypto": "openssl",
            "libz": "zlib",
            "libxml-2.0": "libxml2",
            "libxml": "libxml2"
        }
        
        for pc in discovered_pc:
            name = pc.lower()
            if name in self.common_mapping:
                mapped_deps.add(self.common_mapping[name])
            elif name in internal_mapping:
                mapped_deps.add(internal_mapping[name])
            else:
                # Basic normalization
                name = name.replace("lib", "") if name.startswith("lib") and len(name) > 3 else name
                mapped_deps.add(name)

        return sorted(list(mapped_deps))

    def propose_yaml(self, pkgname, version=None, source_url=None):
        """Generate a proposed YAML configuration."""
        arch_meta = self.fetch_arch_metadata(pkgname)
        
        final_version = version or (arch_meta["version"] if arch_meta else "latest")
        final_url = source_url or (arch_meta["sources"][0] if arch_meta and arch_meta["sources"] else "SKIP")
        deps = arch_meta["depends"] if arch_meta else []
        
        yaml_content = f"name: {pkgname}\n"
        yaml_content += f"version: \"{final_version}\"\n"
        yaml_content += "type: source_build\n"
        yaml_content += "base_hierarchy:\n  - static\n  - base\n  - cc\n\n"
        yaml_content += "dependencies:\n"
        
        # Filter dependencies against a whitelist of what we support as atoms
        # For now, just add them all as 'source' type
        for d in deps:
            # Simple heuristic: if it's a common lib, we probably want it as an atom
            yaml_content += f"  - name: {d}\n    version: \"latest\"\n    type: source\n"
        
        yaml_content += f"\nruntime:\n  name: {pkgname}\n  version: \"{final_version}\"\n"
        yaml_content += f"  source_url: \"{final_url}\"\n"
        yaml_content += "  sha256: \"SKIP\"\n"
        yaml_content += "  build_flags: []\n"
        
        return yaml_content

if __name__ == "__main__":
    discovery = DiscoveryEngine()
    print("Discovery Engine Initialized.")
