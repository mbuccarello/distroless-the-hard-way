# Pipeline Specification: OpenSSL (Cryptography)

The `openssl` component provides the localized cryptographic primitives and SSL/TLS support for the Distroless The Hard Way ecosystem.

---

## 1. Build Implementation Details

Following the Total GNU Alignment strategy, OpenSSL is compiled within a Glibc-native environment to ensure binary compatibility with the core `glibc` layer.

### Sandbox Environment
- **Host System**: Fedora (latest)
- **Source**: `ghcr.io/mbuccarello/base-fedora:latest` (Stage 0 Mirror)
- **Authentication**: Mandatory **Docker Login** to GHCR is required before sandbox pull.

### Compilation Strategy
1. **Source Acquisition**: Raw source is retrieved from the official OpenSSL GitHub repository.
2. **Integrity Verification**: SHA-256 validation ensures the codebase matches the verified secure baseline.
3. **Configuration**: The library is configured for high-throughput cryptography with dynamic loading support disabled where possible.
4. **Reproducibility**: Build artifacts are normalized for deterministic cryptographic output.

---

## 2. Technical Audit & Gating

| Gate | Tool | Specification |
| :--- | :--- | :--- |
| **Integrity** | `sha256sum` | Mandatory hash match for the source tarball. |
| **SAST** | `Semgrep` | Static analysis for insecure cryptographic patterns and memory safety. |
| **SCA** | `Trivy` | Vulnerability scanning of the compiled binaries. |
| **Identity** | `Cosign` | Keyless OIDC signing (Manual Binary Install v2.4.1). |
| **SLSA** | `Attest` | Level 3 Build Provenance via `actions/attest-build-provenance@v2`. |

---

## 3. Artifact Distribution

- **Target**: `ghcr.io/mbuccarello/artifacts-openssl:latest`
- **Format**: OCI artifact containing the compiled OpenSSL shared objects and configuration files.
