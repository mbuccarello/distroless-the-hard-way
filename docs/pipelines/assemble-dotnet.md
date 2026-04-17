> [!NOTE]
> **The Hard Way:** This is an educational tutorial pipeline. Every single step here performs compilation from raw source. We do not use Debian extraction.

# Pipeline Strategy: Opensource Distroless Dotnet Image

The `assemble-dotnet` pipeline creates a high-performance, distroless execution environment for .NET applications, layered on top of the Opensource Distroless `cc` foundation.

## Opensource Distroless Composition Strategy

The pipeline adheres to the **Opensource Distroless Linear Cascade**:
1.  **Stage 1: Verified Ancestry**: Performs a `cosign verify` on the `cc:latest` parent image to ensure it originates from our verified source-to-binary build process.
2.  **Stage 2: Runtime Acquisition**: 
    -   Fetches the official Microsoft .NET Runtime binary (Architecture: x86_64).
    -   Unpacks the runtime inside an ephemeral Alpine extractor to prepare the filesystem layer.
3.  **Stage 3: Distroless Assembly**: 
    -   Starts from our verified `cc:latest` base.
    -   Integrated the .NET runtime files into `/usr/local/dotnet`.
    -   Ensures zero-trust compliance by including only the necessary runtime bits, minimizing the attack surface.

## Zero-Trust Proof Points

### 1. Proof of Mathematical Ancestry
The pipeline proof-of-origin for its base layer (`cc:latest`) is established before assembly. This mathematically links the Dotnet image to the verified foundational layers (`glibc`, `openssl`, `zlib`, `tzdata`).

### 2. Managed Vulnerability Lifecycle
A **Trivy SCA scan** is performed on the final composition. If any high or critical vulnerabilities are detected, the pipeline fails immediately, ensuring only vetted images are pushed to the registry.

## Security Artifacts

| Artifact | Purpose |
| :--- | :--- |
| **OCI Image** | `ghcr.io/${{ github.repository_owner }}/dotnet:latest` |
| **SCA Scan** | **Trivy** scan and SBOM generation. |
| **Signing** | The Dotnet image is signed via **Cosign**. |
| **Provenance** | **SLSA Level 3** build attestation proving the assembly origin. |
