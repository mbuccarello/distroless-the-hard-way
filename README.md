# Distroless The Hard Way

Distroless The Hard Way is an educational and highly technical guide to building secure, minimal OCI container images entirely from upstream source code. It is designed to walk you through the painful but necessary steps of establishing a zero-trust supply chain without relying on pre-compiled distributions.

## Acknowledgments & Inspiration

This project sits at the intersection of three fundamental philosophies in modern infrastructure:

1. **Kubernetes The Hard Way (Kelsey Hightower):** The inspiration for our educational approach. We believe that to truly understand the security and mechanics of minimal containers, you must build them step-by-step from scratch, failing and learning along the way.
2. **Google Distroless (Bazel Architecture):** The structural inspiration for our dependency logic. Google Distroless uses Bazel to rigorously map out and extract exactly the right dependencies for `base`, `cc`, and specific language runtimes (`java`, `python`). We copy this strict architectural layering but replace Bazel's Debian package extraction with pure, native source-code compilation.
3. **Chainguard ("This Shit Is Hard" Philosophy):** The inspiration for our uncompromising zero-trust mindset. We enforce strict capability analysis and supply-chain purity, prioritizing rigorous security over convenience.

---

## Architecture

To guarantee transparency and security, Distroless The Hard Way builds every foundational library in its own isolated GitHub Actions pipeline. These are then layered sequentially, mimicking the Google Distroless dependency graphs.

### 0. The Bootstrap Extractor (Stage 0)
To achieve pure zero-trust during assembly, we cannot rely on pre-compiled extraction tools like Alpine's `tar`. Instead, we natively compile a standalone extractor from pristine source to handle package construction within our `scratch` images.

*   [`build-bootstrap`](docs/pipelines/build-bootstrap.md): The zero-trust static extraction binary.

### 1. The Atomic Foundation Pipelines (Stage 1)
These standalone workflows compile libraries directly from source code (`.tar.gz` archives fetched from upstream). 
By fetching pure source code instead of relying on compromised pre-built binaries, we can statically analyze the codebase, inject our own cryptographic compilation flags, and ensure bit-for-bit reproducibility.

*   [`build-glibc`](docs/pipelines/build-glibc.md): The core C runtime.
*   [`build-openssl`](docs/pipelines/build-openssl.md): Cryptography compiled specifically to deny dynamic linking.
*   [`build-zlib`](docs/pipelines/build-zlib.md): Peak compression throughput.
*   [`build-tzdata`](docs/pipelines/build-tzdata.md): Unpacked chronological profiles.
*   [`build-gcc`](docs/pipelines/build-gcc.md): Heavy C++ compilation strictly to extrapolate the lightweight `libstdc++` runtime libraries.

### 2. The Core Assembler Pipelines (Stage 2)
Once the independent foundations are compiled and signed, the Assembler pipelines logically merge them into OCI images. To adhere to pure zero-trust, we do not use an Alpine container to extract these assets; instead, we rely on a custom Bootstrap extractor.

*   [`assemble-base`](docs/pipelines/assemble-base.md): Combines `glibc`, `openssl`, `zlib`, and `tzdata` into `distroless-the-hard-way/base`.
*   [`assemble-cc`](docs/pipelines/assemble-cc.md): Layers the securely compiled `gcc` C++ footprint onto the `base` image.

### 3. End-to-End Verification (Stage 3)
We implement comprehensive E2E testing to ensure runtime integrity. These tests compile and execute real application code inside the final assembled images.

For a deep dive into verification logic across all runtimes, see the [Runtime Verification Framework (E2E)](docs/e2e-framework.md).

---

## Security & Supply Chain

To maintain a zero-trust posture, we integrate advanced security instrumentation at every stage of the lifecycle:

- **[Static Analysis (Semgrep)](docs/Semgrep.md)**: Auditing source code for vulnerabilities prior to compilation.
- **[Binary Capability Analysis (Malcontent)](docs/Malcontent.md)**: Inspecting finalized binaries for unexpected capabilities or malware.
- **[Keyless Cryptographic Signing](docs/Signing.md)**: Leveraging Sigstore/Cosign OIDC mechanisms for verifiable provenance without static private keys.
- **[Registry Authentication](docs/GHCR-Token.md)**: Securely publishing to the GitHub Container Registry.

---

## Supported Execution Environments

Distroless The Hard Way achieves parity with the traditional Distroless application matrix through our Decoupled Component Architecture.

| Environment | Parent Layer | Status | Upstream Source | Verification Application |
| :--- | :--- | :--- | :--- | :--- |
| **Go / Rust** (Static) | `base` | Live | Native compilation | N/A |
| **Java (17/21)** | `cc` | Live | Adoptium OpenJDK | [HelloOpensource.java](E2E/java/) |
| **Node.js** | `cc` | Live | upstream node source | [index.js](E2E/nodejs/) |
| **Python 3** | `cc` | Live | python-build-standalone | [main.py](E2E/python3/) |
| **.NET** | `cc` | Live | Microsoft source | [HelloOpensource](E2E/dotnet/) |
| **PHP 8.x** | `cc` | Live | php.net | [test.php](E2E/php/) |
| **Perl 5.x** | `cc` | Live | cpan.org | [test.pl](E2E/perl/) |

---

## Technical Architecture

For a complete chronological overview, see our detailed technical guides:
- [Architecture Deep-Dive](docs/architecture.md)
- [Validation & Test Plan](docs/test-plan.md)
- [Version Selection Strategy](docs/strategy/version-selection.md)
- [Pipeline Tutorial Guides](docs/pipelines/)

---

## Repository Structure

```text
distroless-the-hard-way/
├── .github/
│   └── workflows/             # The automated multi-stage compilation pipelines
├── E2E/                       # End-to-End verification applications
├── AGENT.md                   # Project Guardrails and Agent Context (AI system prompt)
├── docs/                      
│   ├── images/                # Static architectural diagrams
│   ├── architecture.md        # Detailed Architecture Guide & Sequence Diagrams
│   └── pipelines/             # Step-by-step technical tutorials
└── poc/                       # Archived Prototype Documentation (fully isolated)
```
