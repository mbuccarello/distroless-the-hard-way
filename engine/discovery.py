import re
import os
import urllib.request
import json

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

    def discover_dependencies(self, source_dir):
        """Analyze a source directory to find dependencies."""
        discovered_pc = set()
        
        # 1. Look for pkg-config checks in configure scripts
        for root, dirs, files in os.walk(source_dir):
            for file in files:
                if file in ["configure", "configure.ac", "Makefile.am"]:
                    path = os.path.join(root, file)
                    with open(path, "r", errors="ignore") as f:
                        content = f.read()
                        # Look for PKG_CHECK_MODULES(NAME, [pc-lib >= ver, ...])
                        matches = re.findall(r'PKG_CHECK_MODULES\([A-Z0-9_]+,\s*\[?([a-zA-Z0-9_.-]+)', content)
                        discovered_pc.update(matches)
                        
        # 2. Map discovered names to our internal names
        mapped_deps = set()
        for pc in discovered_pc:
            if pc in self.common_mapping:
                mapped_deps.add(self.common_mapping[pc])
            else:
                mapped_deps.add(pc) # Fallback to raw name

        return sorted(list(mapped_deps))

    def propose_yaml(self, pkgname, version, source_url, stack_type="source_build"):
        """Generate a proposed YAML configuration for a new stack."""
        # Note: In a real scenario, we would download and extract the source first
        # For now, we return a template that can be filled
        deps = []
        if os.path.exists(os.path.join(self.cache_dir, pkgname, "src")):
            deps = self.discover_dependencies(os.path.join(self.cache_dir, pkgname, "src"))
        
        yaml_content = f"name: {pkgname}\n"
        yaml_content += f"version: \"{version}\"\n"
        yaml_content += f"type: {stack_type}\n"
        yaml_content += "base_hierarchy:\n  - static\n  - base\n  - cc\n\n"
        yaml_content += "dependencies:\n"
        for d in deps:
            yaml_content += f"  - name: {d}\n    version: \"latest\"\n    type: source\n"
        
        yaml_content += f"\nruntime:\n  name: {pkgname}\n  version: \"{version}\"\n"
        yaml_content += f"  source_url: \"{source_url}\"\n"
        yaml_content += "  sha256: \"SKIP\"\n"
        
        return yaml_content

if __name__ == "__main__":
    # Example usage
    discovery = DiscoveryEngine()
    print("Discovery Engine Initialized.")
