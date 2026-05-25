# Distroless The Hard Way

[![Distroless Full Fleet Build](https://github.com/mbuccarello/distroless-the-hard-way/actions/workflows/distroless-fleet-build.yml/badge.svg)](https://github.com/mbuccarello/distroless-the-hard-way/actions/workflows/distroless-fleet-build.yml)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/mbuccarello/distroless-the-hard-way/badge)](https://securityscorecards.dev/viewer/?uri=github.com/mbuccarello/distroless-the-hard-way)

Distroless The Hard Way is a technical framework for constructing minimal, secure OCI container images compiled entirely from source code. The project implements a source-driven supply chain that eliminates reliance on external binary distributions.

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
*   **GitHub Actions**: Specialized workflows handle the sequential chain:
    *   [Foundation: Static (L1)](.github/workflows/distroless-foundation-static.yml)
    *   [Foundation: Base (L2)](.github/workflows/distroless-foundation-base.yml)
    *   [Foundation: CC (L3)](.github/workflows/distroless-foundation-cc.yml)
    *   [Stack: Runtime Assembly](.github/workflows/distroless-stack-runtime.yml)

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
    OPERATIONS.md          # Operations, deployments, and SLSA provenance
    SECURITY.md            # Security, hardening, and supply chain integrity
    PIPELINE_STATUS.md     # Current Fleet Health & Verification Status
```

**[Get Started with the Developer Onboarding Guide](docs/ONBOARDING_GUIDE.md) | [Explore the Core Architecture Design](docs/ARCHITECTURE.md)**

---

## Credits and Inspiration

- **Kubernetes The Hard Way**: The educational blueprint for manual deconstruction.
- **Google Distroless**: The architectural gold standard for minimal OCI images (e.g., `static`, `base`, `cc`, language runtimes). *Distroless The Hard Way* builds upon this standard by introducing modular OCI Atoms for a customized, lightweight `cc` layer and strict FHS symlink preservation.
- **Arch Linux**: The primary intelligence source for dependency mapping and build blueprints.
- **iximiuz Labs**: Inspiration for container filesystem internals, namespace isolation, and robust rootfs design patterns.
