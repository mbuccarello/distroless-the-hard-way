# Distroless The Hard Way

[![E2E Orchestrator](https://github.com/mbuccarello/distroless-the-hard-way/actions/workflows/e2e-orchestrator.yml/badge.svg)](https://github.com/mbuccarello/distroless-the-hard-way/actions/workflows/e2e-orchestrator.yml)
<!-- Audit v48: Runtime Stabilization Verified -->
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/mbuccarello/distroless-the-hard-way/badge)](https://securityscorecards.dev/viewer/?uri=github.com/mbuccarello/distroless-the-hard-way)

Distroless The Hard Way is a technical implementation and educational curriculum for constructing secure, minimal OCI container images from upstream source code. The project implements a zero-trust supply chain architecture that eliminates reliance on pre-compiled distributions.

---

## 🏗️ System Architecture

The build infrastructure is organized into five functional stages, ensuring absolute isolation between source acquisition, compilation, and image assembly. For a detailed view of how shared libraries are inherited across images, see the [Library Hierarchy & Roadmap](docs/lib-hierarchy.md).

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

## 📦 Consumption & Verification

All images are hosted on the **GitHub Container Registry (GHCR)** and are crytographically signed to ensure supply chain integrity.

### 1. Authenticate to GHCR
To pull images, you must authenticate using a [GitHub Personal Access Token (PAT)](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) with `read:packages` scope.

```bash
echo "YOUR_PAT" | docker login ghcr.io -u YOUR_USERNAME --password-stdin
```

### 2. Pull and Run Runtimes
You can pull the distroless images using standard Docker commands:

```bash
# Pull PHP
docker pull ghcr.io/mbuccarello/php:latest

# Run a smoke test
docker run --rm ghcr.io/mbuccarello/php:latest --version
```

### 3. Verify Cryptographic Signatures
We use **Sigstore/Cosign** for keyless signing. You can verify the identity of any image:

```bash
cosign verify --certificate-identity-regexp ".*" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  ghcr.io/mbuccarello/php:latest
```

---

## 🚀 Execution Matrix

| Runtime | Base Layer | Status | Upstream Source |
| :--- | :--- | :--- | :--- |
| **Java** | `cc` | ✅ OK | Eclipse Temurin 21 |
| **Node.js** | `cc` | ✅ OK | Node.js 20 LTS |
| **.NET** | `cc` | ✅ OK | .NET Runtime 8.0 |
| **Python 3** | `cc` | ✅ OK | Fedora Python 3.12 |
| **PHP** | `cc` | ✅ OK | Fedora PHP 8.3 |
| **Perl** | `cc` | ✅ OK | Fedora Perl 5.38 |
| **Go / Rust** | `base` | ✅ OK | Native Binaries |
