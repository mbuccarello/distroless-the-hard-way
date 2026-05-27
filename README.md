# Distroless The Hard Way

[![Distroless Full Fleet Build](https://github.com/mbuccarello/distroless-the-hard-way/actions/workflows/distroless-fleet-build.yml/badge.svg)](https://github.com/mbuccarello/distroless-the-hard-way/actions/workflows/distroless-fleet-build.yml)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/mbuccarello/distroless-the-hard-way/badge)](https://securityscorecards.dev/viewer/?uri=github.com/mbuccarello/distroless-the-hard-way)

Distroless The Hard Way is a technical framework for constructing minimal, secure OCI container images compiled entirely from source code. The project implements a source-driven supply chain that eliminates reliance on external binary distributions.

---

## Quick Start

Our distroless images contain no shell, package manager, or dynamic utilities. You can execute them directly, or use them as a secure foundation in multi-stage builds.

### 1. Run a container directly
Execute our source-compiled, minimal Python 3.14 distroless image:
```bash
docker run --rm ghcr.io/mbuccarello/python-distroless:latest -c "print('Hello from source-built distroless!')"
```

### 2. Multi-Stage Dockerfile Pattern
Use our base layers to build highly secure, shell-free production containers:
```dockerfile
# Build Stage: Compile the app using an ephemeral build container
FROM golang:1.22 AS builder
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 go build -o myapp .

# Runtime Stage: Deploy the binary to our source-built, minimal static layer
FROM ghcr.io/mbuccarello/static:latest
COPY --from=builder /src/myapp /usr/bin/myapp
USER nonroot:nonroot
ENTRYPOINT ["/usr/bin/myapp"]
```

### 3. Keyless Image Verification
All OCI images produced by our fleet pipeline are signed using **Sigstore/Cosign**. You can instantly verify their integrity with zero static keys:
```bash
cosign verify ghcr.io/mbuccarello/python-distroless:latest \
  --certificate-identity-regexp "https://github.com/mbuccarello/distroless-the-hard-way/.github/workflows/distroless-bake-master.yml@.*" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
```
For detailed verification across all runtimes, refer to **[docs/VERIFY.md](docs/VERIFY.md)**.

---

## Architecture: OCI Atoms

The project utilizes a modular architecture where language runtimes (PHP, Python, Node.js) are assembled from versioned, pre-compiled building blocks termed Atoms.

### Core Principles

1.  **Source Control**: All binaries and libraries are compiled from upstream source code to ensure total control over the software supply chain.
2.  **Persistent Atoms**: Dependencies are managed as versioned OCI images in GHCR for high-assurance assembly, replacing transient build layers with reusable artifacts.
3.  **Registry-First Orchestration**: The build engine prioritizes pulling pre-compiled Atoms from the registry, accelerating assembly while maintaining granular provenance.
4.  **Dynamic Metadata Discovery**: A specialized discovery engine extracts dependency graphs and configuration parameters directly from Arch Linux metadata.

### Build Orchestration
The Build Engine (engine/engine.py) manages the assembly process by:
*   Executing in targeted modes: --mode foundation for core layers and --mode runtime for language-specific stacks.
*   Analyzing Arch Linux PKGBUILDs to automate dependency resolution and extract optimized compilation flags.
*   Generating Docker Bake (HCL) manifests (foundations/*.hcl) to ensure ABI consistency across all layers.
*   Enforces a strict **Debug Tagging Strategy**: standard images are shell-free; troubleshooting tools (Busybox) are isolated to `:debug` variants.

### OCI Atoms Inventory & Retrieval

An **OCI Atom** is a single-purpose, versioned OCI image containing a source-compiled C/C++ library or dependency (including dynamic `.so` libraries, headers, metadata, and license files). 

All compiled Atoms are published to the **GitHub Container Registry (GHCR)** in the GitHub Packages ecosystem under `ghcr.io/mbuccarello/atoms/...` (e.g., `ghcr.io/mbuccarello/atoms/openssl:3.6.2`). The build engine dynamically pulls these Atoms into multi-context Docker Bake files (`foundations/*.hcl`) to construct highly customized, minimal `cc` base layers per stack.

#### 1. Retrieve an Atom
You can pull and inspect any Atom locally using standard Docker commands:
```bash
docker pull ghcr.io/mbuccarello/atoms/openssl:3.6.2
```

#### 2. Verify an Atom's Integrity
Every Atom is signed in our fleet pipeline using **Sigstore/Cosign**. You can cryptographically verify an Atom's provenance and chain-of-trust with zero static keys:
```bash
cosign verify ghcr.io/mbuccarello/atoms/openssl:3.6.2 \
  --certificate-identity-regexp "https://github.com/mbuccarello/distroless-the-hard-way/.github/workflows/distroless-bake-master.yml@.*" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
```

#### 3. Core Atoms Inventory
Below is a catalog of the foundational OCI Atoms pre-compiled from upstream source tarballs in this repository:

| Atom Name | Upstream Repository / Sourcing | Purpose in the Stack | Tag Template |
| :--- | :--- | :--- | :--- |
| **`zlib`** | [madler/zlib](https://github.com/madler/zlib) | Lossless data-compression library | `atoms/zlib:<version>` |
| **`openssl`** | [openssl/openssl](https://github.com/openssl/openssl) | Cryptography and TLS engine | `atoms/openssl:<version>` |
| **`ncurses`** | [gnu/ncurses](https://ftp.gnu.org/pub/gnu/ncurses/) | Terminal control and character-cell APIs | `atoms/ncurses:<version>` |
| **`readline`** | [gnu/readline](https://ftp.gnu.org/pub/gnu/readline/) | Command line editing and history features | `atoms/readline:<version>` |
| **`sqlite`** | [sqlite.org](https://www.sqlite.org/) | Lightweight SQL database engine | `atoms/sqlite:<version>` |
| **`libxcrypt`** | [besser82/libxcrypt](https://github.com/besser82/libxcrypt) | Modern cryptographic password hashing | `atoms/libxcrypt:<version>` |
| **`libffi`** | [libffi/libffi](https://github.com/libffi/libffi) | Foreign Function Interface library | `atoms/libffi:<version>` |
| **`expat`** | [libexpat/libexpat](https://github.com/libexpat/libexpat) | Stream-oriented XML parser library | `atoms/expat:<version>` |
| **`bzip2`** | [sourceware.org/bzip2](https://sourceware.org/pub/bzip2/) | High-quality block-sorting file compressor | `atoms/bzip2:<version>` |
| **`xz`** | [tukaani-project/xz](https://github.com/tukaani-project/xz) | LZMA data compression utility and library | `atoms/xz:<version>` |
| **`icu`** | [unicode-org/icu](https://github.com/unicode-org/icu) | International Components for Unicode database | `atoms/icu:<version>` |
| **`nghttp2`** | [nghttp2/nghttp2](https://github.com/nghttp2/nghttp2) | HTTP/2 frame and protocol parser | `atoms/nghttp2:<version>` |
| **`krb5`** | [web.mit.edu/kerberos](https://web.mit.edu/kerberos/) | Kerberos network authentication protocol | `atoms/krb5:<version>` |
| **`libxml2`** | [download.gnome.org](https://download.gnome.org/sources/libxml2/) | XML parsing and processing engine | `atoms/libxml2:<version>` |
| **`curl`** | [curl/curl](https://github.com/curl/curl) | Multi-protocol URL data transfer library | `atoms/curl:<version>` |
| **`pcre2`** | [PCRE2Project/pcre2](https://github.com/PCRE2Project/pcre2) | Perl-compatible regular expressions engine | `atoms/pcre2:<version>` |
| **`oniguruma`** | [kkos/oniguruma](https://github.com/kkos/oniguruma) | Flexible regular expression engine | `atoms/oniguruma:<version>` |
| **`brotli`** | [google/brotli](https://github.com/google/brotli) | Generic-purpose lossless compression library | `atoms/brotli:<version>` |

---

## Language Support Matrix

| Runtime | Base Layer | Sourcing | Status |
| :--- | :--- | :--- | :--- |
| **Python** | `cc` | Source-Built (3.14) | ✅ Active |
| **Node.js** | `cc` | Binary Injection (LTS) | ✅ Active |
| **Java** | `cc` | Binary Injection (21 LTS) | ✅ Active |
| **.NET** | `cc` | Binary Injection (8 LTS) | ✅ Active |
| **Go** | `static` | Static Compilation | ✅ Active |
| **PHP / Perl**| `cc` | Source-Built | ✅ Active |

---

## Security Principles & Hardening

- **Zero OS Extraction**: No reliance on host OS package managers (`apt`, `apk`). We compile from upstream source tarballs.
- **Unified FHS**: All libraries are unified into `/usr/lib` to prevent ABI drift and path complexity.
- **License Extraction**: Automated harvest of license files to ensure open-source compliance.
- **Keyless Signing**: Full Sigstore/Cosign integration for non-falsifiable image verification.
- **SLSA Level 3**: Cryptographic provenance for every layer in the hierarchy.

---

## Usage & CI/CD

The project utilizes a **Tiered Pipeline Hierarchy** powered by specialized Docker Bake manifests.

*   **Foundation Build**: `python3 engine/engine.py --mode foundation && docker buildx bake -f foundations/foundations.hcl cc`
*   **Runtime Assembly**: `python3 engine/engine.py --mode runtime --stack stacks/python.yaml && docker buildx bake -f foundations/python.hcl python`
*   **GitHub Actions**: Specialized workflows handle the sequential build, compilation, and validation chain:
    *   **Core Foundation Tier**:
        *   [Foundation: Static (L1)](.github/workflows/distroless-foundation-static.yml) - Assembles the initial minimal `/` rootfs layout skeleton.
        *   [Foundation: Base (L2)](.github/workflows/distroless-foundation-base.yml) - Injects `glibc` dynamic linker, standard user setups, and NSS domain libraries.
        *   [Foundation: CC (L3)](.github/workflows/distroless-foundation-cc.yml) - Compiles dynamic dynamic ABI runtime C/C++ libraries.
    *   **Runtime Assembly Tier**:
        *   [Stack: Runtime Assembly](.github/workflows/distroless-stack-runtime.yml) - Generates tailored language runtimes (L4) from configured stack blueprints.
    *   **Orchestration & Verification Tier**:
        *   [Fleet Orchestrator](.github/workflows/distroless-fleet-build.yml) - Weekly automated or trigger-based high-concurrency compilation of the entire container runtime family.
        *   [E2E Verification (Fleet)](.github/workflows/distroless-e2e-fleet.yml) - Dynamic smoke-testing verification of the entire runtime fleet sequentially upon successful compilation.
        *   [E2E Verification (Single-Stack)](.github/workflows/distroless-e2e.yml) - Manual or trigger-based test harness to validate a targeted language stack using `/app/` scripts.

---

## Repository Structure

```text
distroless-the-hard-way/
 app/                       # E2E Smoke Test Applications (Perl, PHP, Python, Java, etc.)
 engine/                    # The Modular Build Orchestrator
    engine.py              # Core logic for HCL/Dockerfile generation
    discovery.py           # Dependency lookup and Arch package metadata queries
 foundations/               # The OCI Hierarchy Blueprints & Generated HCL/Dockerfiles
    static.Dockerfile      # L1: Rootfs Skeleton
    base.Dockerfile        # L2: Glibc & NSS Base Layer
    cc.Dockerfile          # L3: Common C/C++ (CC) Base Base Layer
    cc-*.Dockerfile        # Stack-specific ABI C/C++ CC Layers (e.g., cc-php.Dockerfile)
    runtime.Dockerfile     # L4: Final Assembly Template Stage
    *.hcl                  # Target Docker Bake HCL configs (e.g., php.hcl)
 patches/                   # Build-time source patches for dependency compilation
 poc/                       # Proof-of-Concept, initial roadmap, and legacy designs
 stacks/                    # YAML-based language stack definitions (e.g., php.yaml)
 docs/                      # Technical System Specifications & Developer Guides
    ARCHITECTURE.md        # Technical System Specification (4-Layer Model, FHS)
    ONBOARDING_GUIDE.md    # Developer Quick Start & Local Compilation Guide
    ENGINE.md              # Technical manual for engine/engine.py
    PIPELINES.md           # CI/CD tiered pipeline flows & GHA workflows
    TESTING.md             # E2E Smoke Testing and local/CI validation
    OPERATIONS.md          # Operations, deployments, and CA mounting
    SECURITY.md            # Security, hardening, and supply chain integrity
    VERIFY.md              # Keyless Image Verification (Cosign)
    IMAGE_REPORT.md        # Fleet status & real-time metadata report
    PIPELINE_STATUS.md     # Current Fleet Health & Verification Status
```

### Technical System Specifications & Developer Guides (`docs/`)

*   **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - Technical System Specification (4-Layer Model, FHS)
*   **[COMPARISON.md](docs/COMPARISON.md)** - Architectural Comparison & Enterprise Production Readiness Analysis
*   **[ONBOARDING_GUIDE.md](docs/ONBOARDING_GUIDE.md)** - Developer Quick Start & Local Compilation Guide
*   **[ENGINE.md](docs/ENGINE.md)** - Technical manual for the build orchestrator (`engine/engine.py`)
*   **[SCRIPTS.md](docs/SCRIPTS.md)** - Developer Utility & Automation Reference Guide
*   **[PIPELINES.md](docs/PIPELINES.md)** - CI/CD tiered pipeline flows & GitHub Actions workflows
*   **[TESTING.md](docs/TESTING.md)** - E2E Smoke Testing and local/CI validation
*   **[OPERATIONS.md](docs/OPERATIONS.md)** - Operations, deployments, and custom CA certificate mounting
*   **[SECURITY.md](docs/SECURITY.md)** - Security hardening, scanner limitations, and supply chain integrity
*   **[VERIFY.md](docs/VERIFY.md)** - Keyless Image Verification (Cosign)
*   **[IMAGE_REPORT.md](docs/IMAGE_REPORT.md)** - Real-time fleet status & image metadata report

**[Get Started with the Developer Onboarding Guide](docs/ONBOARDING_GUIDE.md) | [Explore the Core Architecture Design](docs/ARCHITECTURE.md) | [Verify Image Signatures](docs/VERIFY.md)**

---

## Credits and Inspiration

- **Kubernetes The Hard Way**: The educational blueprint for manual deconstruction.
- **Google Distroless**: The architectural gold standard for minimal OCI images (e.g., `static`, `base`, `cc`, language runtimes). *Distroless The Hard Way* builds upon this standard by introducing modular OCI Atoms for a customized, lightweight `cc` layer and strict FHS symlink preservation.
- **Arch Linux**: The primary intelligence source for dependency mapping and build blueprints.
- **iximiuz Labs**: Inspiration for container filesystem internals, namespace isolation, and robust rootfs design patterns.
