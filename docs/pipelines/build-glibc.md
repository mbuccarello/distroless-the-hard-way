# Pipeline Specification: GNU C Library (glibc)

The `glibc` library is the foundational runtime for the Distroless The Hard Way ecosystem. All downstream language runtimes rely on this component for kernel syscalls and memory management.

---

## 1. Build Implementation Details

To ensure binary compatibility and prevent system header conflicts, the build is executed within a Glibc-native sandbox.

### Sandbox Environment
- **Host System**: Fedora (latest)
- **Source**: `ghcr.io/mbuccarello/base-fedora:latest`
- **Authentication**: **Docker Login** enabled for secure sandbox pull.
- **Rationale**: Building GNU components on musl-based hosts (e.g., Alpine) is prohibited to prevent environmental contamination of the library's ABI definitions.

### Compilation Strategy
1. **Source Acquisition**: Upstream Glibc source is retrieved from the official GNU mirrors.
2. **Integrity Verification**: SHA-256 validation is performed before any code interaction.
3. **Optimized Build**: The library is compiled with `-O2` and configured for standard system paths.
4. **Reproducibility**: Timestamps are normalized via `SOURCE_DATE_EPOCH` to ensure deterministic output.

---

## 2. Technical Audit & Gating

| Gate | Tool | Specification |
| :--- | :--- | :--- |
| **Integrity** | `sha256sum` | Mandatory hash match against hardcoded reference. |
| **SAST** | `Semgrep` | Static analysis of C code for memory safety vulnerabilities. |
| **SCA** | `Trivy` | Vulnerability scanning of the compiled binaries. |
| **Identity** | `Cosign` | Keyless OIDC signing (Manual Binary Install v2.4.1). |
| **SLSA** | `Attest` | Level 3 Build Provenance via `actions/attest-build-provenance@v2`. |

---

## 3. Artifact Distribution

The finalized library is packaged as an atomic OCI payload:
- **Target**: `ghcr.io/mbuccarello/artifacts-glibc:latest`
- **Format**: Scratch-based container containing the compiled `/usr` and `/lib` hierarchies.
