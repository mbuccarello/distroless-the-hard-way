> [!NOTE]
> **The Hard Way:** This is an educational tutorial pipeline. Every single step here performs compilation from raw source. We do not use Debian extraction.

# Pipeline Strategy: OpenSSL

OpenSSL provides the critical cryptographic layer for the entire Opensource-Distroless stack. It ensures that HTTPS, SSL/TLS handshakes, and certificate verification are handled by a natively compiled, zero-trust binary rather than a black-box OS package.

## Zero-Trust Proof Points

### 1. Verified Source Acquisition
Raw source code is fetched directly from the **OpenSSL GitHub Releases**:
- **Source**: `https://github.com/openssl/openssl/releases/download/openssl-3.2.1/openssl-3.2.1.tar.gz`
- **Integrity**: Hardcoded SHA-256 verification (`83c7329fe52c850677d75e5d0b0ca245309b97e8ecbcfdc1dfdc4ab9fac35b39`) occurs before any build activity.

### 2. Static Analysis (SAST)
The raw C source undergoes a **Semgrep SAST scan** using the high-security `p/c` ruleset. This ensures we identify and mitigate memory safety vulnerabilities in the upstream crypto logic before it reaches production.

### 3. Isolated Sandbox compilation
Compilation occurs within an ephemeral **Alpine Linux sandbox**:
- **Configuration**: Built with `no-shared` to ensure static linking where possible, optimized with `-O3`.
- **Reproducibility**: `SOURCE_DATE_EPOCH` is pinned to ensure that the cryptographic binary is deterministic and reproducible.

## Security Artifacts

| Artifact | Purpose |
| :--- | :--- |
| **OCI Layer** | `ghcr.io/${{ github.repository_owner }}/artifacts-openssl:latest` |
| **SBOM** | Generated via `trivy` in SPDX format for compliance and vulnerability tracking. |
| **Signing** | Cosign-verified OCI artifact. |
| **Provenance** | **SLSA Level 3** build attestation proving the artifact's origin from raw source. |
