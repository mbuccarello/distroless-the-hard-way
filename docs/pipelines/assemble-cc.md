# Pipeline Strategy: Distroless The Hard Way C++ Image (CC)

The `assemble-cc` pipeline extends the `base` image with the natively compiled GNU C++ Runtimes. This creates a foundational execution environment for any application requiring `libstdc++`, `libgcc_s`, or `libgomp` (Java, Node.js, Python, Dotnet, PHP).

## 🏗️ Assembly Process: Additive Layering

The `cc` image extends the `base` environment by adding the GNU C++ runtime:

1.  **Inheritance**: `FROM ghcr.io/[owner]/base:latest`.
2.  **Payload Injection**: The `gcc` foundation tarball is extracted.
3.  **Components**:
    - `libstdc++`: The standard C++ library.
    - `libgcc_s`: GCC support library.
    - `libgomp`: GNU OpenMP runtime (Added for Parity with Google).
4.  **Library Discovery**: `ldconfig` is re-run to index the new C++ libraries.

## 📦 Dependency Chain
`static` -> `base` -> `cc`

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
