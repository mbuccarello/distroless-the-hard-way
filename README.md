# Distroless The Hard Way

[![Foundations](https://github.com/mbuccarello/distroless-the-hard-way/actions/workflows/master-foundations.yml/badge.svg)](https://github.com/mbuccarello/distroless-the-hard-way/actions/workflows/master-foundations.yml)
[![Assembly](https://github.com/mbuccarello/distroless-the-hard-way/actions/workflows/master-assembly.yml/badge.svg)](https://github.com/mbuccarello/distroless-the-hard-way/actions/workflows/master-assembly.yml)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/mbuccarello/distroless-the-hard-way/badge)](https://securityscorecards.dev/viewer/?uri=github.com/mbuccarello/distroless-the-hard-way)

Distroless The Hard Way is a technical implementation and educational curriculum for constructing secure, minimal OCI container images from upstream source code. The project implements a zero-trust supply chain architecture that eliminates reliance on pre-compiled distributions.

---

## System Architecture: The 4-Layer Hierarchy

The project implements a canonical, layered inheritance model inspired by Google Distroless, ensuring maximum minimalism for every workload. For detailed technical specifications, refer to the [System Architecture](docs/architecture.md) and [Library Hierarchy](docs/lib-hierarchy.md).

### Layer 1: Foundations (The Build Payloads)
Independent source-built artifacts containing the raw DNA of the system. Detailed documentation available in [Pipeline Orchestration](docs/pipelines.md).
*   **cacerts**: Sovereign Root Trust Store derived directly from Mozilla NSS source.
*   **glibc**: Core C runtime compiled from GNU source.
*   **openssl**: Cryptography engine.
*   **tzdata**: Timezone database.
*   **gcc/libgomp**: C++ runtime and OpenMP support.

### Layer 2: Core Images (The OCI Roots)
Atomic images constructed from Layer 1 payloads.
*   **static**: The Zero-Layer for pure static binaries (Go, Rust). Contains only certs, tzdata, and sovereign configuration files (passwd, group, netbase).
*   **base**: Inherits from static. Adds glibc and openssl for dynamic C applications.
*   **cc**: Inherits from base. Adds the C++ runtime for complex native extensions.

### Layer 3: Language Runtimes
Language-specific environments built on top of the Core layers.
*   **Interpreted**: PHP, Python, Node.js, Perl.
*   **Compiled/VM**: Java (OpenJDK), .NET (CoreCLR).

### Layer 4: Verification (E2E)
Automated functional assertions that confirm the integrity of the entire stack. Refer to the [E2E Framework](docs/e2e-framework.md) for validation logic.

---

## Execution Matrix

| Runtime | Base Layer | Status | Upstream Source |
| :--- | :--- | :--- | :--- |
| **Go (Static)** | static | OK | Native Static Binary |
| **Go (Cgo)** | base | OK | Dynamic Binary |
| **PHP** | base | OK | Fedora PHP 8.3 |
| **Perl** | base | OK | Fedora Perl 5.38 |
| **Java** | cc | OK | Eclipse Temurin 21 |
| **Node.js** | cc | OK | Node.js 20 LTS |
| **.NET** | cc | OK | .NET Runtime 8.0 |
| **Python 3** | cc | OK | Fedora Python 3.12 |

---

## Security Implementation: The "Hard Way" Principles

- **Sovereign Root Trust**: No reliance on OS vendor CA bundles. Certificates are extracted and built from Mozilla NSS source.
- **Sovereign Netbase**: Manual construction of /etc/services and /etc/protocols to eliminate RPM dependencies.
- **SLSA Level 3 Provenance**: Automated build attestations for every layer. See [SLSA Implementation](docs/SLSA-Level-3.md).
- **Keyless Signing**: Full Sigstore integration for image verification. See [Signing Documentation](docs/Signing.md).
- **Static Analysis**: Source-code auditing via [Semgrep](docs/Semgrep.md).

---

## Repository Structure

```text
distroless-the-hard-way/
├── .github/workflows/         # Layered Orchestration (L1, L2, L3)
├── app/                       # Verification applications (Go, PHP, etc.)
├── docs/                      
│   ├── architecture.md        # Technical System Specification
│   ├── pipelines.md           # Detailed pipeline documentation
│   └── gap-analysis.md        # Roadmap and Google Parity tracking
```

---

## Consumption and Verification

### 1. Authenticate to GHCR
To pull images, you must authenticate using a [GitHub Personal Access Token (PAT)](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) with `read:packages` scope.

```bash
echo "YOUR_PAT" | docker login ghcr.io -u YOUR_USERNAME --password-stdin
```

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
| **Go (Static)** | `static` | ✅ OK | Native Static Binary |
| **Go (Cgo)** | `base` | ✅ OK | Dynamic Binary |
| **PHP** | `base` | ✅ OK | Fedora PHP 8.3 |
| **Perl** | `base` | ✅ OK | Fedora Perl 5.38 |
| **Java** | `cc` | ✅ OK | Eclipse Temurin 21 |
| **Node.js** | `cc` | ✅ OK | Node.js 20 LTS |
| **.NET** | `cc` | ✅ OK | .NET Runtime 8.0 |
| **Python 3** | `cc` | ✅ OK | Fedora Python 3.12 |
