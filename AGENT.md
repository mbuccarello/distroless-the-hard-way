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

## 3. Mandatory Security Implementations
When generating or modifying GitHub Action assembly pipelines, you must include the following validations:
1. **Semgrep:** Source analysis before native compilation.
2. **Keyless Signing:** All intermediate layers and bases must be signed using Sigstore/Cosign OIDC Keyless mechanisms (e.g., `cosign sign --yes`). Do not look for "missing" private keys.
3. **Malcontent:** Every final assembled image must run Chainguard's `malcontent analyze` to prove no arbitrary capabilities or malware were compiled into the final binary.
4. **Trivy:** SBOM/SCA generation.

## 4. Documentation Standards
- **Architectural Documentation Enforcement:** You are strictly prohibited from considering an architectural change (e.g. Pivot to Fedora, new Mirroring layers, Bootstrap modifications) as "Done" until the corresponding `.md` documentation in `docs/` or `README.md` has been updated to reflect the new technical reality.
- **Mandatory Synchronization:** Each time you create a new layer, modify a GitHub Action workflow, or notably change the CI logic, you **must** proactively check if a documentation update in `docs/` is required.
- **Graphical Diagrams (Mermaid):** Agents MUST create a graphical architecture diagram or sequence diagram (using Mermaid syntax) whenever it makes sense to graphically explain the architecture, a related pipeline, or an operative workflow.
- **Educational & Professional Tone:** Documentation must be written as step-by-step tutorials explaining the "why", not just the "how". You must adopt the tone of a senior technical manager. Describe architecture and work academically. Do not use AI filler text, excessive marketing adjectives, or emojis.
- **Archived Prototype:** The old python `build.py` orchestrator in the `poc/` directory is strictly an archived prototype and must not be treated as the primary architecture. Do not cross-link new pipelines to the POC.
