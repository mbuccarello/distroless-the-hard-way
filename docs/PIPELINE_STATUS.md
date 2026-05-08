# Distroless Engine: Pipeline Status & Architecture

This document provides a technical overview of the Distroless Engine, CI/CD orchestration, and the modular OCI Atom build architecture.

## System Status

| Component | Status | Description |
| :--- | :--- | :--- |
| **Engine Core** | Stable | Python-based engine (engine/engine.py) orchestrates HCL and Dockerfile generation using targeted modes. |
| **Fleet Build** | Optimized | Modular matrix build utilizing OCI Atoms to reduce redundant compilation across runtimes. |
| **OCI Atoms** | Active | Dependencies are managed as versioned, persistent OCI images in GHCR for high-assurance assembly. |
| **SLSA L3** | Active | Attestations generated using captured Bake metadata (digest-based signing). |
| **Cosign** | Active | Keyless signing performed on the exact image digest after push. |

## Architecture Overview

### 1. Build Engine (engine/engine.py)
The engine serves as the single source of truth for the image fleet. It performs:
- **Dependency Mapping**: Automatically extracts dependency graphs from Arch Linux PKGBUILDs.
- **HCL Generation**: Dynamically creates Docker Bake (HCL) manifests for targeted atomic builds.
- **Source Orchestration**: Manages the source_build logic, ensuring ABI consistency and hardened compilation flags.
- **Metadata Discovery**: Uses the discovery engine (engine/discovery.py) to map upstream source URLs and configuration parameters.

### 2. Modular OCI Atom Logic
The architecture utilizes versioned Atoms to assemble final runtimes:
- **Registry-First Assembly**: The engine prioritizes pulling pre-compiled library Atoms from GHCR.
- **Isolated Foundations**: Core layers (static, base, cc) are maintained as atomic building blocks.
- **Hardened Runtimes**: Final images are constructed by overlaying Atoms into a shell-less, scratch-based environment.

### 3. CI/CD Orchestration

#### Stack Runtime Assembly (.github/workflows/distroless-stack-runtime.yml)
The primary worker for runtime assembly.
- **Workflow**:
  1. Initialize Engine (Generates modular HCL/Dockerfile).
  2. Execute Docker buildx bake for the targeted runtime.
  3. Extract image digest and sign using Cosign.
  4. Generate and attach SLSA Level 3 attestations.

#### Distroless Full Fleet Build (.github/workflows/distroless-fleet-build.yml)
Orchestrates the entire ecosystem by discovering all stacks and triggering modular builds in sequence, ensuring that foundational changes propagate through the fleet.

## Security & Compliance

- **Keyless Signing**: Integrated **Sigstore/Cosign** into the master workflow, using GitHub OIDC identity for non-falsifiable signatures.
- **Supply Chain Integrity**: Every image and Atom receives a **SLSA Level 3** provenance attestation via the official `actions/attest-build-provenance` action.
- **SBOM Generation**: **Syft** automatically generates CycloneDX JSON SBOMs for every final runtime, attached as build artifacts.
- **Vulnerability Scanning**: **Grype** performs deep scans on every build, ensuring that critical vulnerabilities are identified before deployment.
- **Hardening**: Final images are strictly shell-less and contain zero executables other than the target runtime, minimizing the attack surface.

## Maintenance & Discovery

- **New Runtimes**: New stacks can be quickly onboarded using the **Discovery CLI** (`engine/discovery_cli.py`), which automates YAML generation by analyzing upstream Arch Linux metadata and source code.
- **Lifecycle Management**: Weekly fleet builds ensure that all source components and Atoms are updated and patched against known vulnerabilities.
