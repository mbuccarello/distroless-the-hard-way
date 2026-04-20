> [!NOTE]
> **The Hard Way:** This is an educational tutorial pipeline. Every single step here performs compilation from raw source. We do not use Debian extraction.

# Pipeline Strategy: GNU Compiler Collection (gcc) - C++ Runtimes

The `gcc` pipeline is responsible for producing the foundational C++ execution libraries (`libstdc++`, `libgcc_s`, `libgomp`). These provide the essential runtime environment for high-level languages like Java and Node.js.

## Zero-Trust Proof Points

### 1. Verified Source Acquisition
Raw source code is fetched directly from the **GNU FTP mirror**:
- **Source**: `https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.gz`
- **Integrity**: Hardcoded SHA-256 verification (`e275e76442a60f73b736fdf347b8bfbc23304cbe8e04bf1fde7ae66f108f5127`) occurs before any build activity.

### 2. Static Analysis (SAST)
The raw C++ source underwent a **Semgrep SAST scan** using the `p/c` ruleset. This ensures we identify memory safety issues in the upstream compiler runtime before it is integrated into the Distroless The Hard Way image layers.

### 3. Isolated Sandbox compilation
Compilation occurs within a minimal **Alpine Linux sandbox**:
- **Strategy**: We strictly target `all-target-libstdc++-v3` to isolate the dynamic runtime libraries, discarding the heavy-weight compiler binaries.
- **Reproducibility**: `SOURCE_DATE_EPOCH` is pinned to ensure that the resulting shared objects (`.so`) are deterministic and verifiable.

## Security Artifacts

| Artifact | Purpose |
| :--- | :--- |
| **OCI Layer** | `ghcr.io/${{ github.repository_owner }}/artifacts-gcc:latest` |
| **SBOM** | Generated via `trivy` in SPDX format, indexing the exact versions of the C++ runtimes. |
| **Signing** | OCI artifact signed via Cosign. |
| **Provenance** | **SLSA Level 3** build attestation proving the artifact's chain of custody from GNU source. |
