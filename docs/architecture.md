# Technical Specification: System Architecture

Distroless The Hard Way implements a modular, Decoupled Component Architecture (DCA) to achieve a zero-trust supply chain. The system is designed to provide bit-perfect reproducibility and cryptographic transparency by eliminating reliance on pre-compiled host OS binaries.

---

## 1. Pipeline Lifecycle Specification

The build process is logically partitioned into functional stages. Each stage is isolated to prevent cross-contamination of build environments.

```mermaid
graph TD
    S1[-1: Mirror Registry] --> S0[0: Static Bootstrap]
    S1 --> S1_F[1: Foundations]
    S0 --> S2[2: OS Core Assembly]
    S1_F --> S2
    S2 --> S3[3: Verification]
    
    subgraph "Isolation Zone"
    S1
    S0
    S1_F
    end
```

### Stage 0: Mirror Registry Isolation
To ensure absolute infrastructure resilience and prevent upstream rate-limiting, the system utilizes a local caching tier.
*   **Mandate**: No build environment (Alpine, Fedora) is pulled directly from external registries during library compilation.
*   **Standard**: All build sandboxes must originate from the internal `ghcr.io` mirror.

### Stage 1: Zero-Trust Bootstrap Utility
Assembly of a root filesystem within a `FROM scratch` container requires a self-contained execution toolkit.
*   **Decoupled Requirement**: The system prohibits the use of host-provided `tar`, `sh`, or `mkdir` utilities during image construction.
*   **Specification**: A 100% static, GNU-based BusyBox binary is compiled from source. This utility provides the minimal syscall interface needed for layer extraction and configuration (e.g., `/etc/passwd` generation).

### Stage 2: The GNU-Native Build Strategy
The system enforces strict library compatibility by aligning the build host with the target C implementation.
*   **Glibc Requirement**: Foundational components dependent on the GNU C Library (Glibc, OpenSSL, Zlib) are compiled within a Glibc-native sandbox (Fedora).
*   **Linkage Standard**: Static libraries are utilized where possible, and dynamic libraries are packaged as atomic OCI artifacts to maintain layer integrity.

---

## 2. Security Gateways & Controls

Each component must pass a sequential set of security checkpoints before promotion to the intermediate registry:

1.  **Source Integrity**: Cryptographic SHA-256 verification of raw source archives.
2.  **Static Analysis (SAST)**: Semgrep auditing to detect memory corruption patterns and insecure API usage.
3.  **Binary Attribution**: SLSA Level 3 attestations linking the hashed artifact to the originating build environment and source commit.
4.  **Identity Verification**: Keyless signing (Cosign/Sigstore) tied to the GitHub Action OIDC workload identity.

---

## 3. Atomic Artifact Model

The architecture treats every library as a standalone atomic unit.
- **Packaging**: Components are pushed to the registry as `artifacts-<name>` images.
- **Consumption**: The Stage 3 Assemblers pull these signed payloads and extract them into a clean rootfs. This decoupling allows for independent patching of a single library (e.g., patching `openssl` without rebuilding `glibc`).
