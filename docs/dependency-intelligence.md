# Dependency Intelligence Protocol: Solving the ABI Puzzle

Managing C-library dependencies in a 100% independent distroless image is an engineering challenge. When building from raw source code (`.tar.gz`), there is no package manager to tell you that `readline` needs `ncurses`, or that `ncurses` must be compiled with `wide-character` support to avoid a segmentation fault in Python.

To solve this without relying on vendored solutions, we use **Arch Linux PKGBUILDs** as our Intelligence Source and **Docker Bake** as our Orchestration Engine.

## 1. The Complexity of Dependency Management
A single library like `readline` has hidden requirements:
- **Link-time Dependencies:** It must find `libncursesw.so` during its own compilation.
- **ABI Compatibility:** If `ncurses` was built with a separate `libtinfo.so` but `readline` expects it to be bundled, the resulting binary will crash (Segmentation Fault).
- **Header Resolution:** Headers like `term.h` must be in the correct search path.

## 2. The Translation Protocol (Rosetta Stone)
We translate the human-readable shell scripts from Arch Linux into machine-readable HCL (HashiCorp Configuration Language) for Docker Bake.

### Mapping Table
| Arch Linux (`PKGBUILD`) | Docker Bake (`docker-bake.hcl`) | Purpose |
| :--- | :--- | :--- |
| `depends=(ncurses)` | `contexts = { deps = "target:ncurses" }` | Defines the physical dependency graph. |
| `configure_options=(...)` | `args = { LIB_CONFIG = "..." }` | Standardizes ABI flags across the tree. |
| `provides=(libreadline.so)` | `tags = [".../foundation-python-readline"]` | Defines the output OCI artifact. |

### Example: The `readline` Translation
**Source (Arch Linux):**
```bash
pkgname=readline
depends=(glibc ncurses)
build() {
  ./configure --prefix=/usr
  make SHLIB_LIBS=-lncurses
}
```

**Destination (Our Independent HCL):**
```hcl
target "readline" {
  inherits = ["foundation-base"]
  contexts = {
    deps = "target:ncurses" # Intelligence: derived from 'depends'
  }
  args = {
    LIB_NAME = "readline"
    LDFLAGS_EXTRA = "-lncursesw" # Intelligence: derived from SHLIB_LIBS
  }
}
```

## 3. Proposed Automation: `scripts/generate-foundations.py`
To reach total independence, we propose an automated synchronization script. This script eliminates manual "guessing" by programmatically fetching and parsing Arch Linux recipes.

**Automation Workflow:**
1. **Fetch:** Download the raw `PKGBUILD` from `gitlab.archlinux.org`.
2. **Analyze:** Parse the `depends` array and `configure` flags using regex or a shell parser.
3. **Generate:** Dynamically rewrite `foundations/python/docker-bake.hcl` with the updated dependency graph.
4. **Build:** Trigger `docker buildx bake` to execute the fresh, intelligence-driven graph.

By following this protocol, we ensure that "Distroless The Hard Way" remains purely independent while benefiting from the collective dependency knowledge of the Arch Linux community.
