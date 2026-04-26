[<- Back to Main README](../README.md)

# Pipeline Orchestration: The 4-Tier Sovereign Model

Distroless The Hard Way uses a strictly sequential orchestration model to ensure that every layer is built from verified, signed, and audited components.

## Overview
The pipeline is divided into four logical layers, managed by GitHub Actions:

1.  **Layer 1 (System Foundations)**: Compiles core DNA (glibc, openssl, cacerts).
2.  **Layer 1.5 (Runtime Foundations)**: Compiles shared libraries (libxml2, libffi, ncurses).
3.  **Layer 2 (Assembly)**: Merges payloads into Core Images (static, base, cc).
4.  **Layer 3 (Validation)**: Automated E2E verification of final runtimes.

---

## Layer 1: System Foundations (The Build Payloads)
**Workflow**: `master-foundations.yml`

This layer builds the absolute essentials from source.
- **glibc**: The GNU C runtime.
- **openssl**: The sovereign crypto engine.
- **cacerts**: Trust bundle built from Mozilla NSS source.
- **tzdata**: Timezone database from IANA.

---

## Layer 1.5: Runtime Foundations (Shared Libraries)
**Workflow**: `build-runtime-foundations.yml`

This layer builds the specialized libraries required by modern language interpreters.
- **Sovereign Linking**: These are built against the Stage 1 artifacts.
- **OCI Packages**: Distributed as signed OCI artifacts to ensure supply chain integrity.
- **Components**: libffi, libxml2, ncurses, readline, sqlite, oniguruma, libxcrypt.

---

## Layer 2: Assembly (Core Image Construction)
**Workflow**: `master-assembly.yml`

Assembles the foundational payloads into the canonical Distroless hierarchy.
1.  **assemble-static**: Root layer with sovereign trust and netbase.
2.  **assemble-base**: Dynamic C runtime and OpenSSL.
3.  **assemble-cc**: C++ runtime and OpenMP support.

---

## Layer 3: Validation (E2E Test Suite)
**Workflow**: `master-validation.yml`

Automated functional assertions triggered after successful assembly.
- **Connectivity**: SSL/TLS handshake verification.
- **Integrity**: Binary self-awareness (RPATH) audit.
- **Security**: Non-root user enforcement.

---

## The Sovereign Security Gates
Every artifact in the stack must pass through our high-assurance gate:
1.  **Semgrep Audit**: SAST analysis of build logic.
2.  **Trivy SBOM**: Automated generation and attachment of SPDX manifests.
3.  **Cosign Signing**: Keyless OIDC-based signing.
4.  **SLSA Level 3**: Generation of immutable build provenance.
