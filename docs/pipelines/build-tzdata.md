> [!NOTE]
> **The Hard Way:** This is an educational tutorial pipeline. Every single step here performs compilation from raw source. We do not use Debian extraction.

# Pipeline Strategy: tzdata (Timezone Database)

The `tzdata` pipeline provides the authoritative IANA timezone database for the Opensource-Distroless ecosystem. This ensures that every runtime (Java, Python, Node.js, etc.) can accurately resolve regional times without relying on host-system files.

## Zero-Trust Proof Points

### 1. Verified Source Acquisition
Raw source maps are fetched directly from the **IANA official repository**:
- **Source**: `https://data.iana.org/time-zones/releases/tzdata2024a.tar.gz`
- **Integrity**: Hardcoded SHA-256 verification (`0d0434459acbd2059a7a8da1f3304a84a86591f6ed69c6248fffa502b6edffe3`) occurs before processing.

### 2. Isolated Sandbox Compilation
The timezone compilation (zic) occurs within a minimal **Alpine Linux sandbox**:
- **Output**: The compiled database is installed into `/usr/share/zoneinfo`.
- **Reproducibility**: Pinned `SOURCE_DATE_EPOCH` ensures that the resulting timezone binary blobs are deterministic.

## Security Artifacts

| Artifact | Purpose |
| :--- | :--- |
| **OCI Layer** | `ghcr.io/${{ github.repository_owner }}/artifacts-tzdata:latest` |
| **SBOM** | Generated via `trivy` in SPDX format, indexing every timezone file. |
| **Signing** | Cosign-verified OCI artifact. |
| **Provenance** | **SLSA Level 3** build attestation proving the artifact's chain of custody from IANA. |
