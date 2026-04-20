# Pipeline Specification: tzdata (Timezone Database)

The `tzdata` component provides the IANA Time Zone Database for the Distroless The Hard Way ecosystem.

---

## 1. Build Implementation Details

Starting with version 2024b, the system implements a **Dual-Source** strategy to merge logic and definitions.

### Sandbox Environment
- **Host System**: Fedora (latest)
- **Source**: `ghcr.io/mbuccarello/base-fedora:latest`

### Compilation Strategy
1. **Source Acquisition**: The pipeline fetches two distinct tarballs: `tzcodeYYYYx.tar.gz` (logic) and `tzdataYYYYx.tar.gz` (data).
2. **Merging**: The logic and data are merged in the sandbox to produce a complete database.
3. **Processing**: The `zic` (Zone Information Compiler) is used to generate the binary zone files.

---

## 2. Technical Audit & Gating

| Gate | Tool | Specification |
| :--- | :--- | :--- |
| **Integrity** | `sha256sum` | Dual-hash verification for code and data packages. |
| **Identity** | `Cosign` | Keyless OIDC signing of the OCI artifact. |
| **SLSA** | `Attest` | Level 3 Build Provenance. |

---

## 3. Artifact Distribution

- **Target**: `ghcr.io/mbuccarello/artifacts-tzdata:latest`

