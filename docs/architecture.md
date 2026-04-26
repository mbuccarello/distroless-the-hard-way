# Technical Specification: System Architecture

Distroless The Hard Way implements a modular, Decoupled Component Architecture (DCA) to achieve a zero-trust supply chain. The system is designed to provide bit-perfect reproducibility and cryptographic transparency by eliminating reliance on pre-compiled host OS binaries.

---

## 1. Pipeline Lifecycle Specification (The 3-Tier Master Model)

The build process is managed by a three-tier Master Orchestration system. This structure ensures absolute sequentiality and cryptographic provenance from raw source to final runtime.

![Layered Master Architecture](images/layered-architecture.png)

### Stage 1: Foundations (Source Compilation)
Raw source code archives are verified, audited via Semgrep, and compiled within Glibc-native sandboxes (Fedora-based build environments).
*   **Sandbox Rationale**: Fedora containers are utilized as isolated build environments to ensure toolchain consistency and ABI compatibility with GNU source code.
*   **Sovereign Trust**: cacerts are built directly from Mozilla NSS certdata.txt.
*   **Minimalism**: Only the essential shared objects are packaged as OCI artifacts.

### Stage 2: Core Assembly (OCI Roots)
Foundational payloads are merged into the final OCI root filesystems.
*   **Static Layer**: The zero-dependency root. Implements sovereign netbase (/etc/services, /etc/protocols) and canonical identity files.
*   **Base Layer**: Adds the dynamic C runtime and OpenSSL.
*   **CC Layer**: Adds the C++ runtime and OpenMP support.

---

## 2. OCI-Native Dependency Tracking (Pragmatic Traceability)

Rather than reimplementing a complete package manager and local database (an immense technical undertaking), Distroless The Hard Way leverages the **OCI Specification** as a pragmatic alternative for dependency tracking and security.

By utilizing the OCI Registry as a distributed metadata layer, we achieve high-assurance traceability without the overhead of a runtime package database (`/var/lib/rpm`, etc.).

### 2.1 OCI Artifacts as Packages
Each foundational component (e.g., `glibc`, `openssl`) is compiled and packaged as an independent OCI image. This replaces traditional formats like `.rpm` or `.deb`.
*   **Version Control**: Handled via OCI image tags and immutable SHA-256 digests.
*   **Metadata Storage**: Provenance (SLSA), signatures (Cosign), and bill-of-materials (SBOM) are attached to the OCI artifact in the registry rather than stored inside the image filesystem.

### 2.2 Zero-Footprint Runtime
By abstracting package management to the OCI layer, the final runtime images achieve absolute minimalism:
*   **No Database**: The final image contains zero package manager metadata.
*   **Atomic Assembly**: The Layer 2 orchestrator pulls these "OCI packages" and merges them into the final rootfs. 
*   **Implicit Consistency**: Security audits are performed against the registry's metadata, ensuring that the runtime remains a "pure product" without the overhead of management tooling.

---

## 3. Security Gateways and Controls

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

### Type B: Sovereign Source Compilation (Python, PHP, Perl)
For high-level language runtimes, the system implements a full source-to-binary pipeline.
- **Process**: Interpreters are compiled directly from upstream source tarballs within the project's compilation sandboxes.
- **Sovereign Linking**: These runtimes are linked against sovereign foundational libraries (e.g., `libxml2`, `libffi`, `oniguruma`) rather than host OS packages.
- **Hardened RPATH**: All binaries are built with hardened RPATHs pointing to `/usr/local/lib`, ensuring absolute relocatability and independence from the host OS environment.
- **Traceability**: Full SAST and SCA coverage is applied to the source-build process.

---

## 5. Technical Transparency and Definitions

To ensure absolute clarity for security audits and technical reviews, the following definitions specify the boundaries of the system:

### 5.1 Build Environment (The Workshop)
*   **Tooling**: Fedora 40 containers are used strictly as **compilation sandboxes**.
*   **Rationale**: They provide a stable GNU environment (GCC, Make, Binutils) compatible with the source code of `glibc` and `openssl`.
*   **Boundary**: No RPM databases, package manager metadata, or Fedora-specific configuration files are carried over to the final images.

### 5.2 Sovereign Components (The Hard Way)
A component is classified as **Sovereign** when it meets three criteria:
1.  **Source Provenance**: Derived from upstream source archives (e.g., Mozilla NSS, GNU.org) verified via cryptographic signatures.
2.  **Native Compilation**: Built from scratch within the sandbox, not extracted from pre-compiled OS packages.
3.  **Deterministic Assembly**: Injected into a `FROM scratch` OCI layer using the project's bootstrap utility.

### 5.3 Distroless Runtime (The Product)
*   **Minimalism**: The final OCI images (`static`, `base`, `cc`) contain only the minimal set of shared objects (`.so`) and configuration files required for execution.
*   **No Shell**: No shell (`sh`, `bash`), package manager (`dnf`, `apt`), or coreutils are present in the runtime images.
*   **User Isolation**: All images strictly enforce `USER 65532:65532` (nonroot) by default.

---

For a complete mapping of library inheritance and the roadmap for transitioning components to full native source builds, refer to the [Library Hierarchy & Build Roadmap](lib-hierarchy.md).
