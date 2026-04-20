# Distroless The Hard Way - AI Agent Guardrails (`AGENT.md`)

This file defines the core operating principles, architecture context, and strict guardrails for the `distroless-the-hard-way` repository. 

Whenever you (an AI agent) interact with this repository, you must read and **strictly adhere** to the following architectural rules. Failure to do so violates the primary mandate of the project.

## 1. Project Mission
The goal is an educational curriculum titled **Distroless The Hard Way**. 
It teaches users how to create distroless container images *without* relying on third-party OS ecosystems (such as extracting pre-compiled Ubuntu or Debian packages) to ensure absolute data transparency and zero-trust supply chain isolation. The tone must always remain highly technical, human, and educational ("The Hard Way" philosophy).

## 2. Core Operational Pillars
- **Zero OS Extraction:** You are strictly forbidden from writing workflows that rely on precompiled `.so` library binaries from host OS packages (e.g. `apt`, `apk`).
- **Zero Pre-Built Extraction Shims:** You must never use `alpine` or `ubuntu` containers to unpack intermediate tarballs in CI/CD. All extractions must be handled natively by our custom "Pipeline 0" bootstrap image `ghcr.io/.../bootstrap:latest`.
- **Exec-Form Invocation:** Because we extract directly into empty `scratch` containers without an OS, docker instructions must use **Exec Form** (e.g., `RUN ["/tar", "-xzf", "file.tar.gz"]`) to invoke syscall processes directly rather than relying on `/bin/sh`.
- **Strict Source Compilation:** Agents must rely entirely on verified raw source code (`.tar.gz`) fetched directly from upstream providers. Everything must be natively compiled.
- **The Google Distroless Layered Hierarchy:** The architecture strictly enforces a linear cascading hierarchy spanning `base -> cc -> java/python` specifically modeled against Google's Distroless Bazel architecture.
- **Layered Master Orchestration:** Agents must utilize the tiered orchestrator system (Layer 1: Foundations, Layer 2: Assembly, Layer 3: Validation) to prevent race conditions and ensure cryptographic chain-of-custody.
- **Naming Conventions:** 
    - `base-fedora`: Compilation Sandbox (Layer 1 Mirror). Pulls from Docker Hub, pushes to GHCR.
    - `base`: Distroless OS Foundation (Layer 2 Assembled Product). Built from foundations.
    - `artifacts-*`: Intermediate OCI payloads (tarballs) produced by Layer 1.

## 3. Mandatory Security Implementations
When generating or modifying GitHub Action assembly pipelines, you must include the following validations:
1. **Semgrep:** Source analysis before native compilation.
2. **Keyless Signing:** All intermediate layers and bases must be signed using Sigstore/Cosign OIDC Keyless mechanisms (e.g., `cosign sign --yes`). Do not look for "missing" private keys.
3. **Malcontent:** Every final assembled image must run Chainguard's `malcontent analyze` to prove no arbitrary capabilities or malware were compiled into the final binary.
4. **Trivy:** SBOM/SCA generation.

## 4. Documentation Standards
- **Formal Engineering Tone:** Documentation must be written as objective technical specifications. Phrases such as "We discovered", "I found", or "The fix is" are strictly prohibited. Agents must describe the system state and design rationale as technical facts.
- **Architectural Documentation Enforcement:** Each architectural shift (e.g., build host pivots, staging changes, or bootstrap modifications) is not considered complete until the corresponding `.md` documentation in `docs/` or `README.md` is updated to reflect the new technical specification.
- **Graphical Diagrams (Mermaid):** Technical flows must be visualized using Mermaid syntax.
- **Mermaid-to-Image Standard:** Embedded Mermaid blocks are prohibited. Diagram source must be stored in `docs/mermaid/*.mmd`, rendered to `docs/images/*.png` using the **Docker `mermaid-cli`** engine, and referenced as static assets in the documentation.
- **No Filler Content:** Documentation must focus on the "why" and "how" of the architecture. Avoid AI-generated filler, excessive adjectives, or marketing-style language.
- **Archived Prototype:** The old python `build.py` orchestrator in the `poc/` directory is strictly an archived prototype and must not be treated as the primary architecture. Do not cross-link new pipelines to the POC.
