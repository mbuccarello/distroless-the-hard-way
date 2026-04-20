# Pipeline Strategy: Distroless The Hard Way C++ Image (CC)

The `assemble-cc` pipeline extends the `base` image with the natively compiled GNU C++ Runtimes. This creates a foundational execution environment for any application requiring `libstdc++`, `libgcc_s`, or `libgomp` (Java, Node.js, Python, Dotnet, PHP).

## Distroless The Hard Way Composition Strategy

This pipeline follows the **Linear Cascading Hierarchy** of the architecture:
1.  **Stage 2: Ancestry Verification**: Fetches and cryptographically verifies the `base` image and the atomic `gcc` runtime artifacts using Cosign (Manual Binary v2.4.1).
2.  **Stage 3: Layered Integration**: 
    -   Starts from the `base:latest` image.
    -   Unpacks and overlays the verified C++ shared objects into the system's library paths (`/usr/lib`).
    -   Ensures that only the dynamic runtime libraries are included, keeping the image size and attack surface at the absolute minimum.

## Zero-Trust Proof Points

### 1. Proof of Mathematical Origin
The pipeline performs a `cosign verify` on both parent layers (`base` and `gcc-artifacts`) before assembly. This mathematically proves that the entire C++ environment has a continuous chain of custody back to raw source code.

### 2. No OS-Extracted Binaries
Unlike traditional "distroless" CC images that might pull `libstdc++` from Debian or Ubuntu packages, this image uses libraries that were compiled from scratch in our own isolated **Fedora Glibc-native sandbox**.

## Security Artifacts

| Artifact | Purpose |
| :--- | :--- |
| **OCI Image** | `ghcr.io/${{ github.repository_owner }}/cc:latest` |
| **SCA Scan** | **Trivy** scan performed on the final composition to ensure no high-severity CVEs exist. |
| **Signing** | The final CC image is signed via **Cosign**. |
| **Provenance** | **SLSA Level 3** build attestation via `actions/attest-build-provenance@v2`. |
