[<- Back to Main README](../README.md)

# Pipeline Orchestration: The 3-Tier Model

Distroless The Hard Way uses a strictly sequential orchestration model to ensure that every layer is built from verified, signed, and audited components.

## Overview
The pipeline is divided into three logical layers, managed by GitHub Actions:

1.  **Layer 1 (Foundations)**: Compiles raw source code into OCI payloads.
2.  **Layer 2 (Assembly)**: Merges payloads into OCI images (static, base, cc).
3.  **Layer 3 (Atomic Verification)**: Integrated functional assertions within assembly pipelines.

---

## Layer 1: Foundations (Source Builders)
**Workflow**: master-foundations.yml

This layer is responsible for the "Hard Way" part of the project. It fetches source code, verifies signatures, and compiles binaries.

| Step | Component | Description |
| :--- | :--- | :--- |
| **Build Glibc** | glibc | Compiles the GNU C Library. |
| **Build OpenSSL** | openssl | Compiles the crypto engine. |
| **Build Tzdata** | tzdata | Processes timezone source files. |
| **Build Cacerts** | cacerts | Sovereign Step: Generates trust bundle from Mozilla NSS source. |
| **Build GCC** | gcc | Compiles libstdc++ and libgomp. |

---

## Layer 2: Assembly (Image Construction)
**Workflow**: master-assembly.yml

This layer follows the canonical Distroless hierarchy. Each image is a signed OCI container.

1.  **assemble-static**: 
    - **Base**: scratch
    - **Steps**: Injects cacerts, tzdata, and creates /etc/passwd, /etc/group, /etc/services.
2.  **assemble-base**:
    - **Base**: static
    - **Steps**: Injects glibc and openssl. Runs ldconfig.
3.  **assemble-cc**:
    - **Base**: base
    - **Steps**: Injects C++ runtimes (libstdc++, libgomp).

---

## Layer 3: Verification (E2E Tests)
**Workflow**: e2e-orchestrator.yml

Automated tests that validate the entire stack.

- **Handshake Verification**: Every runtime must perform a successful SSL/TLS handshake against an external target.
- **Identity Verification**: Checks that the nonroot user is enforced.
- **Dependency Verification**: Ensures all shared libraries are correctly linked and discoverable.

---

## Security Gates
Every step in every layer must pass:
1.  **Semgrep Audit**: Static analysis of source and build scripts.
2.  **Cosign Signing**: Keyless OIDC-based image signing.
3.  **SLSA Attestation**: Generation of build provenance.
4.  **SBOM Generation**: Generation and attachment of SPDX SBOMs via Trivy.
