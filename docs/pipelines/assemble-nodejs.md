> [!NOTE]
> **The Hard Way:** This is an educational tutorial pipeline. Every single step here performs compilation from raw source. We do not use Debian extraction.

# Pipeline Strategy: Opensource Distroless Node.js Image

The `assemble-nodejs` pipeline creates a high-performance, distroless execution environment for Node.js applications, layered on top of the Opensource Distroless `cc` foundation.

## Opensource Distroless Composition Strategy

The pipeline follows the **Opensource Distroless Linear Cascade**:
1.  **Stage 1: Verified Ancestry**: Performs a `cosign verify` on the `cc:latest` parent image to ensure it originates from our verified source-to-binary build process.
2.  **Stage 2: Runtime Acquisition**: 
    -   Fetches the official **Node.js LTS** binary (Architecture: x86_64).
    -   **Strict Verification**: Hardcoded SHA-256 verification (`84edbca2...`) occurs before any assembly.
    -   Unpacks the Node.js binaries inside an ephemeral Alpine extractor to prepare the `/rootfs` layer.
3.  **Stage 3: Distroless Assembly**: 
    -   Starts from our verified `cc:latest` base.
    -   Integrates the Node.js runtime into `/usr/local/lib/nodejs`.
    -   Implements standard FHS symlinks for `node` and `npm` via the `ln` utility.

## Zero-Trust Proof Points

### 1. Proof of Mathematical Ancestry
The pipeline proof-of-origin for its base layer (`cc:latest`) is established before assembly. This mathematically links the Node.js image to the verified foundational layers (`glibc`, `openssl`, `zlib`, `tzdata`).

### 2. Managed Vulnerability Lifecycle
A **Trivy SCA scan** is performed on the final composition. The pipeline enforces a strictly vetted environment by failing if high or critical vulnerabilities are detected.

## Security Artifacts

| Artifact | Purpose |
| :--- | :--- |
| **OCI Image** | `ghcr.io/${{ github.repository_owner }}/nodejs:latest` |
| **SCA Scan** | **Trivy** scan and SBOM generation. |
| **Signing** | The Node.js image is signed via **Cosign**. |
| **Provenance** | **SLSA Level 3** build attestation proving the assembly origin. |
