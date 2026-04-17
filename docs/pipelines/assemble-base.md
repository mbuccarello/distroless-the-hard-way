> [!NOTE]
> **The Hard Way:** This is an educational tutorial pipeline. Every single step here performs compilation from raw source. We do not use Debian extraction.

# Pipeline Strategy: Opensource Distroless Base Image

The `assemble-base` pipeline is the first stage of the **Opensource Distroless Assembler**. It combines atomic, source-compiled foundational libraries into a minimal, functional UNIX-like filesystem layout starting from an absolute **FROM scratch** point.

## Opensource Distroless Composition Strategy

Unlike traditional distroless images that extract files from Debian or Ubuntu packages, this image is built using a **Negative Trust Multi-Stage Build**:
1.  **Stage 1: Atomic Collection**: Fetches specific verified OCI artifacts produced by foundational build pipelines: `glibc`, `openssl`, `zlib`, and `tzdata`.
2.  **Stage 2: Secure Extraction**: Uses an ephemeral Alpine container to unpack the verified tarballs into a clean `/rootfs` directory.
3.  **Stage 3: Layout Construction**: 
    -   Initializes `/etc/passwd` and `/etc/group` with minimal non-privilege users.
    -   Sets up the Opensource Distroless FHS (Filesystem Hierarchy Standard).
    -   Configures the default `PATH` and `TZ` (UTC).

## Zero-Trust Proof Points

### 1. Cryptographic Ancestry
The pipeline performs a `cosign verify` on every foundational artifact (`glibc`, `openssl`, etc.) before they are allowed to enter the base image. This ensures that only binaries with a verifiable chain of custody to raw source are included.

### 2. No OS Extraction
This pipeline is architecturally isolated from third-party ecosystems. It does not use `apt`, `apk`, or `yum` to install system libraries. Every byte in the final image is accounted for via the atomic build artifacts.

## Security Artifacts

| Artifact | Purpose |
| :--- | :--- |
| **OCI Image** | `ghcr.io/${{ github.repository_owner }}/base:latest` |
| **SCA Scan** | **Trivy** scan performed on the final composition to ensure no high-severity CVEs exist. |
| **Signing** | The final base image is signed via **Cosign**. |
| **Provenance** | **SLSA Level 3** build attestation proving the assembly was performed by this verified workflow. |
