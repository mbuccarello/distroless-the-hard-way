# Distroless The Hard Way

[![Foundations](https://github.com/mbuccarello/distroless-the-hard-way/actions/workflows/master-foundations.yml/badge.svg)](https://github.com/mbuccarello/distroless-the-hard-way/actions/workflows/master-foundations.yml)
[![Assembly](https://github.com/mbuccarello/distroless-the-hard-way/actions/workflows/master-assembly.yml/badge.svg)](https://github.com/mbuccarello/distroless-the-hard-way/actions/workflows/master-assembly.yml)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/mbuccarello/distroless-the-hard-way/badge)](https://securityscorecards.dev/viewer/?uri=github.com/mbuccarello/distroless-the-hard-way)

Distroless The Hard Way is a technical implementation and educational curriculum for constructing secure, minimal OCI container images from upstream source code. The project implements a zero-trust supply chain architecture that eliminates reliance on pre-compiled distributions.

---

## System Architecture: The 4-Layer Sovereign Hierarchy

The project implements a canonical, layered inheritance model that is now **100% decoupled from Fedora RPMs**. Every binary in the stack is source-built within our high-assurance pipelines.

### Layer 1: System Foundations (GNU-Native)
Independent source-built artifacts containing the raw DNA of the system.
*   **cacerts**: Sovereign Root Trust Store (Mozilla NSS source).
*   **glibc**: Core C runtime (GNU source).
*   **openssl**: Cryptography engine (OpenSSL source).
*   **tzdata**: Timezone database (IANA source).

### Layer 1.5: Runtime Foundations (Shared Libraries)
Sovereign library "packages" distributed as OCI artifacts.
*   **libffi, libxml2, sqlite, ncurses, readline**: Compiled from source and linked against Layer 1.

### Layer 2: Core Images (The OCI Roots)
Atomic, bit-perfect images constructed from Layer 1/1.5 payloads.
*   **static**: The Zero-Layer for pure static binaries.
*   **base**: Adds glibc, openssl, and sovereign netbase.
*   **cc**: Adds the C++ runtime and OpenMP support.

### Layer 3: Language Runtimes
Hardened execution environments utilizing the **RPATH strategy** for native library discovery.

---

## Execution Matrix (Phase 4 Enterprise LTS)

| Runtime | Base Layer | Sovereignty | Upstream Version |
| :--- | :--- | :--- | :--- |
| **Go (Static)** | static | Full | 1.22+ |
| **PHP** | base | Full (Source) | 8.3.11 |
| **Perl** | base | Full (Source) | 5.38.2 |
| **Python 3** | cc | Full (Source) | 3.12.5 |
| **Java** | cc | Hardened | Eclipse Temurin 21 (LTS) |
| **Node.js** | cc | Hardened | Node.js 22 (LTS) |
| **.NET** | cc | Hardened | .NET Runtime 8.0 (LTS) |

---

## Security Implementation: The Sovereign Principles

- **Zero RPM Dependency**: No reliance on host OS package managers. We use the OCI registry as a distributed, high-assurance package manager.
- **Hardened RPATH**: Binaries are "self-aware" of their library paths, eliminating `LD_LIBRARY_PATH` hacks.
- **Keyless Signing**: Full Sigstore/Cosign integration for image verification.
- **SLSA Level 3**: Automated provenance for every layer.

---

## Repository Structure & Documentation Index

The project is structured logically to separate operational configuration from architectural documentation and testing.

```text
distroless-the-hard-way/
├── .github/workflows/         # Layered Orchestration (L1, L2, L3)
├── app/                       # Verification applications (Go, PHP, etc.)
├── debug/                     # Local debugging environments for each runtime
├── docs/                      # Core Documentation Directory
│   ├── architecture.md        # Technical System Specification
│   ├── arch-evolution.md      # Historical context on dynamic linking challenges
│   ├── lib-hierarchy.md       # Detailed breakdown of the sovereign libraries
│   ├── pipelines.md           # Deep dive into the GitHub Actions orchestration
│   ├── debugging.md           # Guide on using the local `debug/` environments
│   ├── gap-analysis.md        # Roadmap and Google parity tracking
│   ├── e2e-framework.md       # Functional validation framework
│   ├── test-plan.md           # High-level E2E strategy
│   ├── SLSA-Level-3.md        # Supply chain security compliance
│   ├── Signing.md             # Keyless signature verification guides
│   ├── Semgrep.md             # Static analysis configuration
│   ├── GHCR-Token.md          # Registry authentication
│   └── Malcontent.md          # Policy enforcement for supply chain
```

**[Explore the full documentation in the `docs/` directory.](docs/)**


---

## Consumption and Verification

### 1. Authenticate to GHCR
```bash
echo "YOUR_PAT" | docker login ghcr.io -u YOUR_USERNAME --password-stdin
```

### 2. Pull and Run Runtimes
```bash
# Pull and run a smoke test
docker run --rm ghcr.io/mbuccarello/php:latest --version
```

### 3. Verify Cryptographic Signatures
```bash
cosign verify --certificate-identity-regexp ".*" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  ghcr.io/mbuccarello/base:latest
```

---

## Credits and Inspiration

This project is a synthesis of foundational initiatives in the cloud-native and security ecosystems:

- **Kubernetes The Hard Way**: The educational blueprint for understanding complex systems through manual deconstruction.
- **Chainguard "This Shit is Hard"**: Inspiration for maintaining lean, secure, and current container operating systems. [Read the series](https://www.chainguard.dev/unchained/this-shit-is-hard-keeping-chainguard-os-lean-current-and-secure-the-power-of-garbage-collection).
- **Google Distroless**: The architectural gold standard for minimal OCI images. This project implements the canonical hierarchy defined in their Bazel specifications:
    - [Distroless Static BUILD](https://github.com/GoogleContainerTools/distroless/blob/main/static/BUILD)
    - [Distroless Base README](https://github.com/GoogleContainerTools/distroless/blob/main/base/README.md)
    - [Distroless CC README](https://github.com/GoogleContainerTools/distroless/blob/main/cc/README.md)
