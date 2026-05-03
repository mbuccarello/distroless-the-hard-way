[<- Back to Main README](../README.md)

# Technical Specification: Unified Distroless Architecture

This document defines the high-assurance architecture of the **Distroless The Hard Way** project. The system is designed to provide bit-perfect reproducibility and cryptographic transparency by eliminating reliance on pre-compiled host OS distributions.

---

## 1. The Unified Linear Hierarchy (The 4-Layer Model)

The architecture enforces a strictly linear cascading hierarchy modeled after Google's Distroless Bazel specifications. Each layer inherits only from its direct predecessor, ensuring absolute ABI stability and zero-trust supply chain isolation.

### Layer 1: System Foundations (`static`)
The absolute root of the system. Built from `scratch`, it contains only the essential metadata and trust stores.
*   **Root Trust**: Mozilla NSS CA-certificates.
*   **Identity**: Minimal `passwd` and `group` definitions (root and nonroot).
*   **Netbase**: Declarative `/etc/protocols` and `/etc/services`.
*   **Timezone**: IANA `tzdata` database.

### Layer 2: Dynamic Foundation (`base`)
The execution foundation for dynamic binaries.
*   **C Runtime**: GNU C Library (`glibc`).
*   **Universal ELF Compliance**: Standardized symlinks (`/lib -> /usr/lib`, `/lib64 -> /usr/lib`) ensuring the dynamic linker can resolve dependencies across all Linux kernels.
*   **Networking**: Name Service Switch (NSS) libraries for functional DNS resolution (`libnss_dns`, `libresolv`).

### Layer 3: ABI-Stabilized Foundation (`cc`)
The C++ and core library foundation.
*   **Runtime Libraries**: `libgcc_s` and `libstdc++`.
*   **Core Libraries**: ABI-stabilized versions of `openssl`, `zlib`, `libxcrypt`, and others, all built from source.

### Layer 4: Language Runtimes (`runtime`)
Language-specific execution environments (Python, Node.js, Java, .NET, PHP, Perl).
*   **Sourcing Policy**: 
    *   **Source-Built**: Runtimes built from upstream tarballs (e.g., Python, PHP, Perl).
    *   **Binary Injection**: Official vendor-certified binaries (e.g., Node.js, Java, .NET) injected into our hardened foundation.

---

## 2. The Distroless Engine (Unified Orchestration)

Build orchestration is managed by the **Distroless Engine** (`distroless_engine.py`), which replaces manual pipelines with a data-driven, metadata-first approach.

### 2.1 Dependency Intelligence (Arch Linux PKGBUILD)
To avoid guessing ABI flags or dependency trees, the engine parses **Arch Linux PKGBUILD** scripts as its primary intelligence reference. This ensures that every source-built component is compiled with the most optimized and stable industry-standard flags.

### 2.2 Declarative Bake Orchestration
The engine generates complex **Docker Bake (HCL)** manifests. This allows for:
*   **Parallel Library Builds**: Independent libraries are compiled in isolated Docker contexts.
*   **Atomic Assembly**: The final images are assembled via a single `docker buildx bake` command, ensuring a bit-perfect merge of all foundational layers.

---

## 3. FHS Unification & Library discovery

To prevent ABI drift and path complexity, the architecture unifies all libraries into a single location.
*   **Primary Path**: `/usr/lib`.
*   **Discovery**: Binaries are compiled with hardened `LDFLAGS` (`-Wl,-rpath,/usr/lib`) to ensure they prioritize our sovereign foundations over host libraries.
*   **Security**: The use of `LD_LIBRARY_PATH` is strictly prohibited in production images.

---

## 4. Security Gateways and Compliance

Each layer must pass a sequential set of security checkpoints:
1.  **License Extraction**: Automated harvesting of license files into `/usr/share/doc/`.
2.  **Trivy SBOM**: Automated generation and attachment of SPDX manifests.
3.  **Keyless Signing**: Cosign verification tied to GitHub OIDC identity.
4.  **SLSA Level 3**: Immutable build provenance attestations.

---

## 5. Debugging vs. Production

The architecture enforces a strict **Shell-Free Production** standard.
*   **Standard Images**: Zero executables (no `sh`, `ls`, etc.).
*   **Debug Variants**: Troubleshooting tools (Busybox) are isolated into `:debug` tagged images, created via the same linear hierarchy but including a non-root-accessible Busybox environment.
