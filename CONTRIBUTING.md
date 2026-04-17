# Contributing to Opensource-Distroless

Thank you for your interest in contributing to Opensource-Distroless! We are on a mission to build a zero-trust, 100% sovereign OS ecosystem.

## 🏗 Architectural Rules
Before contributing, please read **`GEMINI.md`**. This repository follows strict architectural pillars:
1. **Zero OS Extraction**: No `.so` binaries from existing OS packages.
2. **Strict Source Compilation**: Everything must be compiled from raw `tar.gz` source.
3. **Mandatory Documentation Synchronization**: Every logic change requires an accompanying documentation update in `docs/pipelines/`.

## 🛠 Development Workflow
1. **Fork the Repo**: Create your feature branch.
2. **Follow the Stages**: Ensure your addition fits into the `Stage 1 (Atomic) -> Stage 2 (Base) -> Stage 3 (App)` flow.
3. **Add Security Gates**: Every new pipeline *must* include:
   - **SAST**: Semgrep for source code.
   - **SCA**: Trivy for container images.
   - **Signing**: Cosign for OCI artifacts.
4. **Automated Smoke Tests**: Add a `docker run --version` check for any new application runtime.

## 📝 Documentation
Documentation is stored in `docs/`. 
- **Mermaid Diagrams**: Store raw source in `docs/mermaid/`.
- **Rendered Images**: Store high-quality `.png` renders in `docs/images/`.

## 🚀 Pull Requests
- Ensure all CI/CD workflows pass.
- Provide a clear explanation of which sovereign component you are adding or improving.
- Update the application matrix in `README.md` if applicable.
