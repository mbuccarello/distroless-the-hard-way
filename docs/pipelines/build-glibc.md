> [!NOTE]
> **The Hard Way:** This is an educational tutorial pipeline. Every single step here performs compilation from raw source. We do not use Debian extraction.

# Pipeline Strategy: GNU C Library (glibc)

The `glibc` pipeline is the absolute bedrock of the Opensource-Distroless ecosystem. Every other runtime (Dotnet, Java, Python, Node.js) relies on this foundational library for kernel syscalls and memory management.

## Zero-Trust Proof Points

### 1. Verified Source Acquisition
We do not trust pre-compiled OS packages. The pipeline fetches the raw source directly from the **GNU FTP mirror**:
- **Source**: `https://ftp.gnu.org/gnu/glibc/glibc-2.39.tar.gz`
- **Integrity**: Hardcoded SHA-256 verification (`f34083833ff32a82fa22c544fa9c6d3df8e4200fdfb9da7082318712ddb19fc7`) occurs before any compilation starts.

### 2. Static Analysis (SAST)
Before compilation, the raw C source undergoes a **Semgrep SAST scan** using the `p/c` (C/C++) ruleset to identify potential buffer overflows or security vulnerabilities in the upstream code.

### 3. Isolated Sandbox Compilation
Compilation occurs within a minimal, ephemeral **Alpine Linux sandbox**. This ensures that host-system contamination is architecturally impossible. 
- **Flags**: Optimized with `-O2` and configured with `--disable-werror` for compatibility.
- **Reproducibility**: `SOURCE_DATE_EPOCH` is pinned to `315532800` (1980) to ensure deterministic binary output.

## Security Artifacts

| Artifact | Purpose |
| :--- | :--- |
| **OCI Layer** | `ghcr.io/${{ github.repository_owner }}/artifacts-glibc:latest` (Scratch-based tarball) |
| **SBOM** | Generated via `trivy` in SPDX format, documenting every compiled header and object. |
| **Signing** | Keyless signing via **Cosign** linked to GitHub Actions OIDC. |
| **Provenance** | **SLSA Level 3** build attestation proving the artifact came from this specific workflow. |
