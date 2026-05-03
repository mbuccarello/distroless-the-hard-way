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
All builds are orchestrated by the **Distroless Engine** (`distroless_engine.py`), which:
*   Parses **Arch Linux PKGBUILDs** to automatically map dependency graphs and extract optimized `./configure` flags.
*   Generates complex **Docker Bake (HCL)** workflows to ensure bit-perfect builds and ABI consistency.
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

The project utilizes a **Unified Master Pipeline** powered by Docker Bake.

*   **Manual Build**: `./distroless_engine.py --stack stacks/python.yaml && docker buildx bake runtime`
*   **GitHub Actions**: Use the [Distroless Bake Master](.github/workflows/distroless-bake-master.yml) to build and sign any stack.
*   **Fleet Updates**: The [Fleet Build](.github/workflows/distroless-fleet-build.yml) orchestrates weekly security updates for the entire OCI catalog.

---

## 📂 Repository Structure

```text
distroless-the-hard-way/
├── distroless_engine.py       # The Unified Build Orchestrator
├── stacks/                    # YAML-based language stack definitions
├── Dockerfile                 # The master hierarchy template
├── docs/                      # Technical System Specifications
│   ├── ARCHITECTURE.md        # Technical System Specification
│   ├── OPERATIONS.md          # Maintenance & Testing Guide
│   ├── SECURITY.md            # Security & Supply Chain Integrity
│   └── PIPELINE_STATUS.md     # Current Fleet Health Report
```

**[Explore the full technical documentation in the `docs/` directory.](docs/ARCHITECTURE.md)**

---

## Credits and Inspiration

- **Kubernetes The Hard Way**: The educational blueprint for manual deconstruction.
- **Google Distroless**: The architectural gold standard for minimal OCI images.
- **Arch Linux**: The primary intelligence source for dependency mapping and build blueprints.
