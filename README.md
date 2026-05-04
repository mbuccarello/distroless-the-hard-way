# Distroless The Hard Way

[![Distroless Full Fleet Build](https://github.com/mbuccarello/distroless-the-hard-way/actions/workflows/distroless-fleet-build.yml/badge.svg)](https://github.com/mbuccarello/distroless-the-hard-way/actions/workflows/distroless-fleet-build.yml)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/mbuccarello/distroless-the-hard-way/badge)](https://securityscorecards.dev/viewer/?uri=github.com/mbuccarello/distroless-the-hard-way)

Distroless The Hard Way is a technical implementation and educational curriculum for constructing secure, minimal OCI container images from upstream source code. The project implements a zero-trust supply chain architecture that eliminates reliance on pre-compiled distributions.

---

## 🏗️ System Architecture: The Unified Distroless Hierarchy

The project implements a canonical, 4-layer inheritance model inspired by Google's Distroless architecture, now orchestrated by a unified, data-driven engine.

### The Linear Chain
1.  **`static`**: The absolute root. Contains CA certificates, timezone data, and basic user/group definitions. Zero executables.
2.  **`base`**: The dynamic foundation. Adds Glibc and critical networking libraries (NSS). Standardized symlinks (`/lib`, `/lib64`) ensure universal kernel compliance.
3.  **`cc`**: The ABI-stabilized layer. Contains the GCC runtime and core C/C++ libraries (OpenSSL, Zlib, etc.) all built from source.
4.  **`runtime`**: The language-specific layer (Python, Node.js, Java). Supports both source-built and official binary injection strategies.

### ⚙️ The Distroless Engine
All builds are orchestrated by the **Distroless Engine** ([engine/engine.py](engine/engine.py)), which:
*   Operates in **targeted modes**: `--mode foundation` for core infrastructure and `--mode runtime` for language stacks.
*   Parses **Arch Linux PKGBUILDs** to automatically map dependency graphs and extract optimized `./configure` flags.
*   Generates specialized **Docker Bake (HCL)** manifests ([foundations/*.hcl](foundations/)) to ensure bit-perfect builds and ABI consistency.
*   Enforces a strict **Debug Tagging Strategy**: standard images are shell-free; troubleshooting tools (Busybox) are isolated to `:debug` variants.

---

## 📊 Language Support Matrix

| Runtime | Base Layer | Sourcing | Status |
| :--- | :--- | :--- | :--- |
| **Python** | `cc` | Source-Built (3.14) | ✅ Active |
| **Node.js** | `cc` | Binary Injection (LTS) | ✅ Active |
| **Java** | `cc` | Binary Injection (21 LTS) | ✅ Active |
| **.NET** | `cc` | Binary Injection (8 LTS) | ✅ Active |
| **Go** | `static` | Static Compilation | ✅ Active |
| **PHP / Perl**| `cc` | Source-Built | ✅ Active |

---

## 🛡️ Sovereign Principles & Security

- **Zero OS Extraction**: No reliance on host OS package managers (`apt`, `apk`). We compile from upstream source tarballs.
- **Unified FHS**: All libraries are unified into `/usr/lib` to prevent ABI drift and path complexity.
- **License Extraction**: Automated harvest of license files to ensure open-source compliance.
- **Keyless Signing**: Full Sigstore/Cosign integration for non-falsifiable image verification.
- **SLSA Level 3**: Cryptographic provenance for every layer in the hierarchy.

---

## 🚀 Usage & CI/CD

The project utilizes a **Tiered Pipeline Hierarchy** powered by specialized Docker Bake manifests.

*   **Foundation Build**: `python3 engine/engine.py --mode foundation && docker buildx bake -f foundations/foundations.hcl cc`
*   **Runtime Assembly**: `python3 engine/engine.py --mode runtime --stack stacks/python.yaml && docker buildx bake -f foundations/python.hcl python`
*   **GitHub Actions**: Specialized workflows handle the sequential chain:
    *   [Foundation: Static (L1)](.github/workflows/distroless-foundation-static.yml)
    *   [Foundation: Base (L2)](.github/workflows/distroless-foundation-base.yml)
    *   [Foundation: CC (L3)](.github/workflows/distroless-foundation-cc.yml)
    *   [Stack: Runtime Assembly](.github/workflows/distroless-stack-runtime.yml)

---

## 📂 Repository Structure

```text
distroless-the-hard-way/
├── engine/                    # The Modular Build Orchestrator
│   └── engine.py              # Core logic for HCL/Dockerfile generation
├── foundations/               # The OCI Hierarchy Blueprints
│   ├── static.Dockerfile      # L1: Rootfs Skeleton
│   ├── base.Dockerfile        # L2: Glibc & NSS
│   ├── cc.Dockerfile          # L3: ABI-stabilized C/C++ Layer
│   └── runtime.Dockerfile     # L4: Final Assembly Template
├── stacks/                    # YAML-based language stack definitions
├── docs/                      # Technical System Specifications
│   ├── architecture.md        # Technical System Specification
│   ├── security.md            # Security & Supply Chain Integrity
│   └── pipeline_status.md     # Current Fleet Health Report
```

**[Explore the full technical documentation in the `docs/` directory.](docs/ARCHITECTURE.md)**

---

## Credits and Inspiration

- **Kubernetes The Hard Way**: The educational blueprint for manual deconstruction.
- **Google Distroless**: The architectural gold standard for minimal OCI images.
- **Arch Linux**: The primary intelligence source for dependency mapping and build blueprints.
