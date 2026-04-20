# Distroless The Hard Way

[![E2E Orchestrator](https://github.com/mbuccarello/distroless-the-hard-way/actions/workflows/e2e-orchestrator.yml/badge.svg)](https://github.com/mbuccarello/distroless-the-hard-way/actions/workflows/e2e-orchestrator.yml)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/mbuccarello/distroless-the-hard-way/badge)](https://securityscorecards.dev/viewer/?uri=github.com/mbuccarello/distroless-the-hard-way)

Distroless The Hard Way is a technical implementation and educational curriculum for constructing secure, minimal OCI container images from upstream source code. The project implements a zero-trust supply chain architecture that eliminates reliance on pre-compiled distributions.

---

## 🏗️ System Architecture

The build infrastructure is organized into five functional stages, ensuring absolute isolation between source acquisition, compilation, and image assembly.

### Stage 0: Mirror Isolation (Registry Hygiene)
To prevent upstream rate-limiting and ensure infrastructure resilience, foundational build-time images (e.g., Alpine, Fedora) are cached within an internal registry.
*   [`mirror-base`](.github/workflows/mirror-base.yml): Automated caching of trusted build-time sandboxes.

### Stage 1: The Static Bootstrap (Zero-Trust Assembly)
Image assembly within a `FROM scratch` environment requires a self-contained execution tool. This stage compiles a 100% static GNU-based BusyBox utility from pristine source.
*   [`build-bootstrap`](docs/pipelines/build-bootstrap.md): The zero-trust static extraction and configuration binary.

### Stage 2: Atomic Foundation (GNU-Native Compilation)
Foundational libraries are compiled from raw source code archives verified via SHA-256 signatures. To prevent musl/glibc header conflicts, all GNU components are built within Glibc-native sandboxes (Fedora).
*   [`build-glibc`](docs/pipelines/build-glibc.md): The core C runtime.
*   [`build-openssl`](docs/pipelines/build-openssl.md): Cryptography engine.
*   [`build-zlib`](docs/pipelines/build-zlib.md): Compression library.
*   [`build-tzdata`](docs/pipelines/build-tzdata.md): Dual-source (code + data) timezone database.

### Stage 3: OS Core Assembly
Intermediate signed payloads from Stage 2 are logically merged into the final OCI root filesystem using the Stage 1 Bootstrap utility.
*   [`assemble-base`](docs/pipelines/assemble-base.md): Construction of the minimal `base` image.
*   [`assemble-cc`](docs/pipelines/assemble-cc.md): Layering of the C++ runtime libraries.

### Stage 4: End-to-End Verification
Automated functional assertions confirm the runtime integrity of the assembled images.
*   [Runtime Verification Framework](docs/e2e-framework.md)

---

## 🛡️ Security Implementation

The project enforces high-assurance supply chain controls at every lifecycle point:

- **SLSA Level 3 Provenance**: Automated build attestations link OCI images to immutable source commits.
- **Keyless Signing**: Continuous cryptographic identity via Sigstore/Cosign OIDC mechanisms.
- **Static Analysis**: Source-code auditing via Semgrep before compilation.
- **Binary Capability Analysis**: Capability and malware inspection via Chainguard Malcontent.

---

## 📂 Repository Structure

```text
distroless-the-hard-way/
├── .github/workflows/         # Automated multi-stage pipelines
├── E2E/                       # Runtime verification test cases
├── AGENT.md                   # AI Agent Guardrails & Technical Mandates
├── docs/                      
│   ├── architecture.md        # Technical System Specification
│   ├── pipelines/             # Implementation tutorials
│   └── operations/            # Day 2 maintenance and constraints
```

---

## 🚀 Execution Matrix

| Environment | Base Layer | Status | Upstream Source |
| :--- | :--- | :--- | :--- |
| **Go / Rust** | `base` | Operational | Native Binary |
| **Java** | `cc` | Operational | Eclipse Temurin |
| **Node.js** | `cc` | Operational | Node.js LTS |
| **Python 3** | `cc` | Operational | CPython |
