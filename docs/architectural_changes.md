# Architectural Changes: Migration to Distroless Bake Build System

This document records the architectural shifts, trade-offs, and final hierarchy established for the unified Distroless build engine.

## 📊 Comparison: Current vs. New

| Feature | Action-based (Old) | Distroless Bake (New) | Rationale |
| :--- | :--- | :--- | :--- |
| **Orchestration** | Fragmented YAML workflows (`assemble-java.yml`, etc.) | Unified Distroless Engine (`generate_bake.py`) | Centralizes logic and dependency graph. |
| **Dependency Management** | Manual `COPY --from=cc:latest` | Automated Bake Hierarchy (`static` -> `base` -> `cc`) | Ensures absolute ABI consistency and reuse. |
| **Artifact Source** | Pre-built binaries (Old) | **Hybrid Distroless Approach** | Core libs are source-built; Runtimes are official binaries (where possible). |
| **Parallelization** | Sequential workflow steps | Native Docker Buildx graph execution | Faster, more efficient builds. |
| **Maintainability** | Hardcoded URLs/SHAs in YAML | Metadata fetched from Arch PKGBUILDs & YAML configs | Reduced manual toil and automated updates. |

---

## 🏗️ The Distroless Hierarchy: Component Inventory (Bazel-Aligned)

We are strictly following the architectural standards set by Google's `distroless` project. Each layer is an atomic, FHS-compliant increment in a linear chain.

### 1. Target: `static` (The Minimalist Root)
*   **Role:** The fundamental root for statically linked binaries (Go, Rust).
*   **Hierarchy:** The absolute root (`FROM scratch`).
*   **Filesystem:**
    *   `/etc/ssl/certs/ca-certificates.crt`: Root trust store.
    *   `/usr/share/zoneinfo`: Timezone database.
    *   `/etc/os-release`: OS metadata.
    *   `/etc/passwd` & `/etc/group`: Including `root` (0) and `nonroot` (65532).
    *   `/tmp` (Sticky 1777), `/home/nonroot`, `/var/lib/apt/lists` (Empty).
*   **Libraries:** **NONE.**

### 2. Target: `base` (The Dynamic Linker)
*   **Role:** Adds the Glibc runtime for C-based applications.
*   **Hierarchy:** `FROM static`.
*   **Libraries (Unified in `/usr/lib`):** 
    *   `/usr/lib/ld-linux-x86-64.so.2` (The Dynamic Linker, typically symlinked to `/lib64/` for legacy compatibility).
    *   `/usr/lib/libc.so.6`, `/usr/lib/libm.so.6`, `/usr/lib/libdl.so.2`, `/usr/lib/libpthread.so.0`, `/usr/lib/librt.so.1` (Glibc Core).
    *   `/usr/lib/libnss_dns.so.2`, `/usr/lib/libnss_files.so.2`, `/usr/lib/libresolv.so.2` (NSS Networking, required for DNS).

### 3. Target: `cc` (The High-Fidelity Foundation)
*   **Role:** The shared ABI-stabilized foundation for all dynamic runtimes.
*   **Hierarchy:** `FROM base`.
*   **System Runtimes (Unified in `/usr/lib`):**
    *   `/usr/lib/libgcc_s.so.1`, `/usr/lib/libstdc++.so.6` (GCC Runtime).
*   **Core Libraries (Source-Built, Unified in `/usr/lib`):**
    *   `/usr/lib/libcrypto.so.3`, `/usr/lib/libssl.so.3` (OpenSSL).
    *   `/usr/lib/libz.so.1` (Zlib).
    *   `/usr/lib/libcrypt.so.2` (Libxcrypt).
    *   `/usr/lib/libffi.so.8` (Libffi).
    *   `/usr/lib/libexpat.so.1` (Expat).

### 📂 Full Filesystem Structure (`cc` Target)
To provide absolute clarity on the layout, this is the expected filesystem state of the final `cc` image before any language runtime is added:

```text
/
├── etc/
│   ├── os-release
│   ├── passwd                 # root(0), nonroot(65532)
│   ├── group
│   ├── debian_version
│   └── ssl/
│       └── certs/
│           └── ca-certificates.crt
├── home/
│   └── nonroot/               # Owned by UID 65532
├── lib -> usr/lib             # Distroless Symlink
├── lib64 -> usr/lib           # Distroless Symlink
├── tmp/                       # Permissions: 1777 (Sticky)
├── usr/
│   ├── lib/
│   │   ├── ld-linux-x86-64.so.2
│   │   ├── libc.so.6
│   │   ├── libcrypto.so.3
│   │   ├── libdl.so.2
│   │   ├── libexpat.so.1
│   │   ├── libffi.so.8
│   │   ├── libgcc_s.so.1
│   │   ├── libm.so.6
│   │   ├── libnss_dns.so.2
│   │   ├── libnss_files.so.2
│   │   ├── libpthread.so.0
│   │   ├── libresolv.so.2
│   │   ├── librt.so.1
│   │   ├── libssl.so.3
│   │   ├── libstdc++.so.6
│   │   └── libz.so.1
│   └── share/
│       └── zoneinfo/          # Timezone database
└── var/
    └── lib/
        └── apt/
            └── lists/         # Empty (distroless spec)
```

## ⚙️ The Unified Distroless Engine: Deep Dive
The refactoring of `generate_bake.py` into a "Unified Engine" means transitioning from a static script to a **Data-Driven Build Orchestrator**.

### **Core Components of the Engine:**
1.  **Metadata Manager:** 
    *   Loads `stacks/*.yaml` to understand the build graph.
    *   Supports multiple "Fetchers": `ArchFetcher` (for PKGBUILDs) and `ReleaseFetcher` (for official binaries).
2.  **DAG Resolver:** 
    *   Calculates the linear build order for the `cc` layer and language stacks.
    *   Ensures that common libraries (like `zlib`) are only built once and reused as `contexts`.
3.  **HCL Generator:** 
    *   Produces a `docker-bake.hcl` that maps the DAG into physical Docker stages.
    *   Manages "Inheritance" between targets (e.g., ensuring `cc` inherits from `base`).
### **Visualizer Design System (Strict Dark Theme)**
To ensure maximum clarity and a premium feel, all generated DAGs will adhere to a **Strict Dark Theme** policy:
*   **Palette:** Primary (#1f6feb blue), Secondary (#238636 green), Border (#30363d), Background (Dark/Transparent).
*   **Zero Vintage:** Absolute prohibition of yellow, parchment, or "vintage" styling.
*   **Output:** High-resolution PNG and Mermaid source.

## ⚙️ Distroless Engine: End-to-End DAG Orchestration
The "Brain" of the engine is a **Full-Stack Dependency & ABI Guard**.

### **How the Engine Handles the Entire Chain:**
1.  **Global DAG Resolution:**
    *   The DAG Resolver is **NOT** limited to `cc`. It manages the entire chain: `static -> base -> cc -> [runtime]`.
    *   It recursively traverses the `depends=` tree from Arch PKGBUILDs for every node in the chain.
    *   It ensures that if `base` (Glibc) is updated, all downstream targets (`cc`, `python`, etc.) are identified for rebuild.
2.  **ABI Flag Propagation:**
    *   The engine enforces a global `ABI_SPEC`. All components (including the core `glibc` in `base`) are forced to use compatible security and feature flags.
3.  **Linkage Verification:**
    *   During the HCL generation, the engine calculates the exact `LDFLAGS` (e.g., `-Wl,-rpath,/usr/lib`) to ensure that runtimes look for libraries in our sovereign `cc` layer first.

### **Artifact Sourcing Policy (Source vs. Binary)**

| Stack | Core Libraries | Runtime Engine | Rationale |
| :--- | :--- | :--- | :--- |
| **Python** | **Source** (Distroless Core) | **Source** (3.14) | Maximum control over ABI alignment. |
| **Node.js** | **Source** (Distroless Core) | **Official Binary** | Official V8 optimization & LTS support. |
| **Java** | **Source** (Distroless Core) | **Official Binary** | Temurin/OpenJDK certified compatibility. |
| **.NET** | **Source** (Distroless Core) | **Official Binary** | Microsoft certified runtime stability. |

---

## 🛠️ Migration Strategy

### Phase 1: Engine Universalization (Modularization) - COMPLETE
*   Implemented `distroless_engine.py`.
*   Codified `static -> base -> cc` hierarchy.
*   Automated Mermaid DAG generation.

### Phase 2: Language Stack Migration - COMPLETE
*   **Python**: Fully migrated to YAML-driven engine.
*   **Node.js**: Fully migrated to YAML-driven engine.
*   **Java**: Fully migrated to YAML-driven engine.
*   **.NET**: Fully migrated to YAML-driven engine.
*   **PHP**: Fully migrated to YAML-driven engine.
*   **Perl**: Fully migrated to YAML-driven engine.

### Phase 3: Final Verification and Cleanup - IN PROGRESS
*   Perform E2E build of the entire hierarchy.
*   Verify license extraction and FHS compliance.
*   Retire all legacy "assemble-*" workflows (Move to `deprecated/`).
