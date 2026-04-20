# Technical Specification: System Architecture

Distroless The Hard Way implements a modular, Decoupled Component Architecture (DCA) to achieve a zero-trust supply chain. The system is designed to provide bit-perfect reproducibility and cryptographic transparency by eliminating reliance on pre-compiled host OS binaries.

---

## 1. Pipeline Lifecycle Specification (Layered Master Model)

The build process is managed by a three-tier Master Orchestration system. This structure eliminates race conditions by enforcing strict sequentiality between architectural layers.

```mermaid
graph TD
    Push["Git Push to main"] --> F["Master Foundations"]
    
    subgraph Layer1 ["Layer 1: Foundations (GNU-Native Builders)"]
        F --> B1["build-openssl"]
        F --> B2["build-zlib"]
        F --> B3["build-tzdata"]
        F --> B4["build-bootstrap"]
        B1 --> G["build-glibc"]
        B2 --> G
        G --> GC["build-gcc"]
    end
    
    GC --> A["Master Assembly"]
    
    subgraph Layer2 ["Layer 2: Assembly (Image Construction)"]
        A --> AB["assemble-base"]
        AB --> AC["assemble-cc"]
        AC --> L1["assemble-java"]
        AC --> L2["assemble-python"]
        AC --> L3["assemble-nodejs"]
    end
    
    L1 --> V["Master Validation"]
    L2 --> V
    L3 --> V
    
    subgraph Layer3 ["Layer 3: Validation (E2E)"]
        V --> E2E["e2e-orchestrator"]
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
