# Distroless Sovereign Engine: Pipeline Status & Architecture

This document provides a comprehensive overview of the current status of the Distroless Engine, the CI/CD orchestration, and the sovereign build philosophy.

## 🚀 Current Status

| Component | Status | Description |
| :--- | :--- | :--- |
| **Engine Core** | ✅ Stable | Python-based engine (`distroless_engine.py`) handles HCL and Dockerfile generation. |
| **Fleet Build** | ✅ Optimized | Parallel matrix build excluding foundations (static, base, cc) to reduce redundancy. |
| **Bake Master** | ✅ Verified | Manual Bake orchestration with local context resolution (fixes `lstat` errors). |
| **SLSA L3** | ✅ Active | Attestations generated using captured Bake metadata (digest-based signing). |
| **Cosign** | ✅ Active | Keyless signing performed on the exact image digest after push. |
| **Dotnet Stack** | ✅ Fixed | Updated to stable version `8.0.26` (fixed `400 Bad Request` from Microsoft). |

## 🏗️ Architecture Overview

### 1. Sovereign Engine (`distroless_engine.py`)
The engine is the single source of truth for the entire fleet. It performs:
- **DAG Resolution**: Resolves library dependencies for each language stack.
- **HCL Generation**: Dynamically creates `docker-bake.hcl` for atomic builds.
- **Dockerfile Assembly**: Generates `Dockerfile.cc` with multi-stage logic for shell-less runtime assembly.
- **Visual Documentation**: Automatically renders Mermaid DAGs to PNG diagrams.

### 2. Multi-Stage Assembly Logic
To maintain a hardened, shell-less environment while allowing flexible runtime installation:
- **`runtime-setup` stage**: Uses the `builder` stage (Arch Linux) to download and extract binaries or compile source.
- **`runtime` stage**: A final `scratch`-based image where artifacts are copied into a clean `/usr` root.

### 3. CI/CD Orchestration

#### **Distroless Bake Master** (`.github/workflows/distroless-bake-master.yml`)
The atomic worker for a single stack.
- **Inputs**: `stack` name and `push` boolean.
- **Flow**:
  1. Initialize Engine (Generates HCL/Dockerfile).
  2. Manual `docker buildx bake` with local context.
  3. Extract Digest from metadata.
  4. Sign with Cosign.
  5. Generate SLSA Attestation.

#### **Distroless Full Fleet Build** (`.github/workflows/distroless-fleet-build.yml`)
The orchestrator for the entire ecosystem.
- **Matrix**: Dynamically discovers all YAML files in `stacks/`.
- **Filtering**: Automatically excludes `static`, `base`, and `cc` foundations from the matrix (as they are implicitly built by the runtimes) to optimize runner usage.

## 🛡️ Security & Compliance
- **Keyless Signing**: Uses GitHub OIDC identity with Cosign.
- **SLSA Level 3**: Every image has an associated provenance document linked to its specific digest.
- **Hardening**: Final images have no shell, no package manager, and run as a non-root user (65532).

## 🛠️ Maintenance & Next Steps
- **New Runtimes**: To add a new runtime, simply create a `stacks/<name>.yaml` and it will be automatically picked up by the fleet build.
- **Weekly Sync**: Scheduled builds run every Sunday to ensure all dependencies are updated and patched.
