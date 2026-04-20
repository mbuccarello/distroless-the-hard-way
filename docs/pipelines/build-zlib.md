# Pipeline Specification: zlib (Compression)

The `zlib` component provides the standard compression algorithms for the Distroless The Hard Way ecosystem.

---

## 1. Build Implementation Details

Following the Total GNU Alignment strategy, zlib is compiled within a Glibc-native environment.

### Sandbox Environment
- **Host System**: Fedora (latest)
- **Source**: `ghcr.io/mbuccarello/base-fedora:latest`
- **Authentication**: **Docker Login** required for sandbox image access.

### Compilation Strategy
1. **Source Acquisition**: Raw source is retrieved from the official zlib GitHub repository.
2. **Integrity Verification**: SHA-256 validation ensures source purity.
3. **Reproducibility**: Binaries are normalized for deterministic output.

---

## 2. Technical Audit & Gating

| Gate | Tool | Specification |
| :--- | :--- | :--- |
| **Integrity** | `sha256sum` | Mandatory hash match. |
| **SAST** | `Semgrep` | Static analysis of the compression logic. |
| **SCA** | `Trivy` | Continuous vulnerability scanning. |
| **Identity** | `Cosign` | Keyless OIDC signing (Manual Binary Install v2.4.1). |
| **SLSA** | `Attest` | Level 3 Build Provenance via `actions/attest-build-provenance@v2`. |

---

## 3. Artifact Distribution

- **Target**: `ghcr.io/mbuccarello/artifacts-zlib:latest`

