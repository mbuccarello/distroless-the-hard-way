> [!NOTE]
> **The Hard Way:** This is an educational tutorial pipeline. Every single step here performs compilation from raw source. We do not use Debian extraction.

# Pipeline Strategy: zlib

The `zlib` pipeline provides the core compression and decompression algorithms for the Opensource-Distroless foundations, primarily used by the dynamic runtime binaries and the OCI layer assembly.

## Zero-Trust Proof Points

### 1. Verified Source Acquisition
Raw source code is fetched directly from the **Zlib Home Page**:
- **Source**: `https://zlib.net/zlib-1.3.1.tar.gz`
- **Integrity**: Hardcoded SHA-256 verification (`9a93b2b7dfdac77ceba5a558a580e74667dd6fede4585b91eefb60f03b72df23`) ensures the source hasn't been tampered with.

### 2. Static Analysis (SAST)
The raw C source undergoes a **Semgrep SAST scan** using both `security-audit` and `secrets` rulesets to detect upstream security flaws or accidentally committed credentials before any compilation occurs.

### 3. Isolated Sandbox compilation
Compilation is performed in a minimal **Alpine Linux sandbox**:
- **Configuration**: Built with optimized `-O3` flags for high-performance compression.
- **Reproducibility**: Pinned `SOURCE_DATE_EPOCH` ensures a deterministic and verifiable binary output.

## Security Artifacts

| Artifact | Purpose |
| :--- | :--- |
| **OCI Layer** | `ghcr.io/${{ github.repository_owner }}/artifacts-zlib:latest` |
| **SBOM** | Generated via `trivy` in SPDX format for transparent dependency tracking. |
| **Signing** | OCI artifact signed via Cosign. |
| **Provenance** | **SLSA Level 3** build attestation linked to the verified source. |
