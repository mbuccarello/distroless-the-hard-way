# Pipeline Strategy: GNU Compiler Collection (gcc) - C++ Runtimes

The `gcc` pipeline is responsible for producing the foundational C++ execution libraries (`libstdc++`, `libgcc_s`, `libgomp`). These provide the essential runtime environment for high-level languages like Java, Node.js, and Dotnet.

## Zero-Trust Proof Points

### 1. Robust Source Integrity (GPG + Redundancy)
Source code is fetched directly from the **GNU FTP mirror** and verified via a multi-tier cryptographic process:
- **Strategy**: The system attempts to fetch GPG signing keys from multiple keyservers (Ubuntu, OpenPGP, MIT) to handle upstream downtime.
- **Verification**: If GPG verification succeeds, the source is promoted. If keyservers are unreachable, the system utilizes a **hardcoded SHA-256 fallback** (`e275e764...`) as a safety net.

### 2. Static Analysis (SAST)
The raw C++ source is audited via **Semgrep** using the `p/c` and `p/security-audit` rulesets. This detects memory corruption patterns and insecure API usage in the compiler runtime before integration.

### 3. Glibc-Native Fedora Sandbox
Compilation occurs within a **Fedora Linux sandbox** from our internal mirror to ensure 100% ABI compatibility with the target Glibc implementation.
- **Authentication**: The builder performs an explicit **Docker Login** to GHCR before pulling the sandbox, ensuring authorization.
- **Isolated Build**: We strictly target `all-target-libstdc++-v3` to isolate the dynamic runtime libraries.
- **Reproducibility**: `SOURCE_DATE_EPOCH` is pinned for bit-perfect deterministic builds.

## Security Artifacts

| Artifact | Purpose |
| :--- | :--- |
| **OCI Layer** | `ghcr.io/${{ github.repository_owner }}/artifacts-gcc:latest` |
| **SBOM** | Generated via `trivy` in SPDX format, indexing the exact versions of the C++ runtimes. |
| **Signing** | OCI artifact signed via Cosign (Manual Binary Install v2.4.1). |
| **Provenance** | **SLSA Level 3** build attestation via `actions/attest-build-provenance@v2`. |
