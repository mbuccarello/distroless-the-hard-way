# Sovereign Distroless Architecture: Technical Specification

This document defines the high-assurance architecture of the **Distroless The Hard Way** project. It combines the technical hierarchy, the dependency orchestration engine, and the sovereign supply chain principles into a single unified reference.

---

## 1. The Unified Linear Hierarchy (The 4-Layer Model)

The architecture enforces a strictly linear cascading hierarchy modeled after Google's Distroless specifications. Each layer inherits only from its direct predecessor, ensuring absolute ABI stability and zero-trust supply chain isolation.

| Layer | Target | Role | Pipeline | Source | Inheritance |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **L0** | `builder` | Toolchain Foundation | Shared | `foundations/builder.Dockerfile` | `fedora:40` |
| **L1** | `static` | System Foundations | `foundation-static` | `foundations/static.Dockerfile` | `scratch` |
| **L2** | `base` | Dynamic Foundation | `foundation-base` | `foundations/base.Dockerfile` | `static:latest` |
| **L3** | `cc` | ABI-Stabilized Base | `foundation-cc` | `foundations/cc.Dockerfile` | `base:latest` |
| **L4** | `runtime` | Language Stack | `stack-runtime` | `foundations/runtime.Dockerfile` | `cc:latest` |

### FHS Unification Standard
To prevent ABI drift, all libraries are unified into `/usr/lib`. Standardized symlinks (`/lib -> /usr/lib`, `/lib64 -> /usr/lib`) ensure universal kernel compliance across all execution environments.

### 📂 Canonical Filesystem Layout (`cc` layer)
Every sovereign image adheres to the following layout before the language runtime is injected:

```text
/
├── etc/
│   ├── ld.so.conf              # Dynamic Linker Configuration
│   ├── os-release              # OS Metadata
│   ├── passwd                  # root(0), nonroot(65532)
│   ├── group
│   └── ssl/
│       └── certs/
│           └── ca-certificates.crt # Root Trust Store
├── home/
│   └── nonroot/                # Owned by UID 65532
├── lib -> usr/lib              # Legacy Library Symlink
├── lib64 -> usr/lib64          # 64-bit ABI Symlink (Fedora compat)
├── tmp/                        # Permissions: 1777 (Sticky)
├── usr/
│   ├── bin/
│   │   └── busybox             # Only in :debug variants
│   ├── lib/                    # Standard Library Path
│   │   └── (32-bit/Universal)
│   ├── lib64/                  # Primary 64-bit Library Path
│   │   ├── ld-linux-x86-64.so.2 # Glibc Dynamic Linker
│   │   ├── libc.so.6           # Glibc Core
│   │   ├── libcrypto.so.3      # OpenSSL
│   │   ├── libssl.so.3         # OpenSSL
│   │   ├── libstdc++.so.6      # GCC Runtime
│   │   └── libz.so.1           # Zlib
│   └── share/
│       └── zoneinfo/           # Timezone Database
└── var/
    └── lib/
        └── apt/
            └── lists/          # Empty (Distroless spec)
```

---

## 2. The Distroless Engine (Unified Orchestration)

Build orchestration is managed by the **Sovereign Engine** (`distroless_engine.py`), a data-driven build orchestrator.

### 2.1 Dependency Intelligence
The engine parses **Arch Linux PKGBUILD** scripts as its primary intelligence reference. This allows the project to:
- Automatically map complex dependency trees.
- Extract industry-standard optimized `./configure` flags.
- Ensure ABI compatibility by forcing all source-built components to use unified `ABI_SPEC` flags.

### 2.2 Declarative Bake Orchestration
The engine generates complex **Docker Bake (HCL)** manifests. This allows for native parallelization of library builds and atomic assembly of the final images.

### 2.3 Isolated Build-Prefix Strategy
To ensure build-time stability and prevent symbol leakage, the engine enforces a strict isolation policy:
- **Build Prefix**: All dependencies (zlib, openssl, etc.) are installed into `/opt/distroless` during the builder stage.
- **Environment Pinning**: `CPPFLAGS`, `LDFLAGS`, and `PKG_CONFIG_PATH` are strictly pointed to `/opt/distroless`.
- **System Tool Safety**: This prevents custom libraries from overwriting system tools in the builder (e.g., preventing `curl` from breaking due to ABI conflicts with our custom OpenSSL).

### 2.4 Multi-Stage Assembly Logic
To maintain a hardened, shell-less environment:
- **`foundations/` Location**: All Dockerfiles are modularized and stored in the `/foundations` directory.
- **`runtime-setup` Stage**: A tool-rich environment (Fedora 40) used to download, compile, or extract runtime binaries into a `/runtime-root`.
- **`runtime` Stage**: The final production image, created by copying artifacts from `/runtime-root` into a clean distroless root.

---

## 3. Fleet Orchestration & Deployment

### **Atomic Worker: Bake Master**
The `distroless-bake-master.yml` workflow builds a single stack atomically. It resolves the entire dependency graph in a single context, guaranteeing that every image is built against the exact same foundation layers.

### **Fleet Orchestrator: Full Fleet Build**
The `distroless-fleet-build.yml` provides global synchronization. It dynamically discovers all stacks in `stacks/` and triggers parallel builds. It optimizes runner usage by excluding foundation-only stacks (`static`, `base`, `cc`), as these are implicitly built by the runtimes.

---

## 4. Security & Supply Chain Integrity

### 4.1 Zero-Trust Principles
- **Zero OS Extraction**: No reliance on host OS package managers.
- **Rpath Pinning**: Binaries are compiled with `-Wl,-rpath,/usr/lib` to ensure they only load sovereign libraries.
- **Shell-Free Production**: Standard images contain zero executables (`no sh`, `no ls`).

### 4.2 Compliance & Attestation
- **License Harvesting**: Automated extraction of licenses into `/usr/share/doc/`.
- **Keyless Signing**: Full Sigstore/Cosign integration using GitHub OIDC identity.
- **SLSA Level 3**: Cryptographic provenance attestations for every layer, linked to the specific image digest.

### 4.3 Debugging Strategy
Troubleshooting tools (Busybox) are strictly isolated into `:debug` tagged variants. These are generated from the same secure hierarchy but include a non-root-accessible diagnostic environment.

---

## 5. Architectural Evolution (Legacy Migration)

The project migrated from fragmented YAML-based workflows to the unified Python-driven engine to solve:
1. **ABI Inconsistency**: Libraries were previously built in separate jobs, leading to linker mismatches.
2. **Maintenance Toil**: Updating a library version required manual edits across dozens of files.
3. **Build Velocity**: Transitioned from sequential steps to native Docker Buildx graph execution.

*This document serves as the authoritative technical reference for the Sovereign Distroless project.*
