# Technical Specification: System Architecture

Distroless The Hard Way implements a modular, Decoupled Component Architecture (DCA) to achieve a zero-trust supply chain. The system is designed to provide bit-perfect reproducibility and cryptographic transparency by eliminating reliance on pre-compiled host OS binaries.

---

## 1. Pipeline Lifecycle Specification (The 3-Tier Master Model)

The build process is managed by a three-tier Master Orchestration system. This structure ensures absolute sequentiality and cryptographic provenance from raw source to final runtime.

![Layered Master Architecture](images/layered-architecture.png)

### Stage 1: Foundations (Source Compilation)
Raw source code archives are verified, audited via Semgrep, and compiled within Glibc-native sandboxes.
*   **Sovereign Trust**: cacerts are built directly from Mozilla NSS certdata.txt.
*   **Minimalism**: Only the essential shared objects are packaged as OCI artifacts.

### Stage 2: Core Assembly (OCI Roots)
Foundational payloads are merged into the final OCI root filesystems.
*   **Static Layer**: The zero-dependency root. Implements sovereign netbase (/etc/services, /etc/protocols) and canonical identity files.
*   **Base Layer**: Adds the dynamic C runtime and OpenSSL.
*   **CC Layer**: Adds the C++ runtime and OpenMP support.

---

## 2. Security Gateways and Controls

Each component must pass a sequential set of security checkpoints before promotion to the intermediate registry:

1.  **Source Integrity**: Cryptographic SHA-256 verification of raw source archives.
2.  **Static Analysis (SAST)**: Semgrep auditing to detect memory corruption patterns and insecure API usage.
3.  **Binary Attribution**: SLSA Level 3 attestations linking the hashed artifact to the originating build environment and source commit.
4.  **Identity Verification**: Keyless signing (Cosign/Sigstore) tied to the GitHub Action OIDC workload identity.

---

---

## 4. Hybrid Provenance Strategy (The Official Path)

To balance the core requirement of "The Hard Way" (bit-perfect integrity) with the objective of "Zero-Compilation" in the assembly phase, the system implements a dual-path acquisition strategy for language runtimes.

### Type A: Native Binary Alignment (Java, Node.js, .NET)
For projects that publish official, standalone binary distribution tarballs, the system performs a direct download from the project's primary mirror.
- **Verification**: Strict cryptographic pinning against official project manifest metadata (e.g., Node.js SHASUMS256, Adoptium API).
- **Benefit**: Ensures the runtime is exactly as intended by the language maintainers without any intermediary modification.

### Type B: OS-Native Package Extraction (Python, PHP, Perl)
For projects that officially distribute only source code (requiring OS-level compilation), the system extracts binaries from **Official Fedora 40 Repositories**.
- **Process**: The system uses the `base-fedora` sandbox to fetch official RPMs via `dnf download --resolve`. These RPMs are then extracted in the runner using `rpm2cpio`.
- **Integrity**: Leverages the binary signing and security patching provided by the Fedora Project maintainers.
- **Alignment**: Ensures 100% ABI compatibility with the `glibc` and core libraries established in Stage 2 (Foundations).

---

For a complete mapping of library inheritance and the roadmap for transitioning components to full native source builds, refer to the [Library Hierarchy & Build Roadmap](lib-hierarchy.md).
