# Contributing to Distroless-The-Hard-Way

Thank you for your interest in contributing to Distroless-The-Hard-Way! We are on a mission to build a zero-trust, 100% sovereign OS ecosystem.

## Architectural Rules
Before contributing, please read **`AGENT.md`**. This repository follows strict architectural pillars:
1. **Zero OS Extraction**: No `.so` binaries from existing OS packages.
2. **Strict Source Compilation**: Everything must be compiled from raw `tar.gz` source (see `docs/ARCHITECTURE.md` §3 for the documented exceptions — Node.js, Java, and .NET runtimes are binary-injected, not source-compiled).
3. **Mandatory Documentation Synchronization**: Every logic change requires an accompanying documentation update in `docs/PIPELINES.md` or the relevant `docs/*.md` file.

## Development Workflow
1. **Fork the Repo**: Create your feature branch.
2. **Follow the Tiers**: Ensure your addition fits into the `L1 (static) -> L2 (base) -> L3 (cc) -> L4 (runtime)` model described in `docs/ARCHITECTURE.md`.
3. **Add Security Gates**: Every new pipeline *must* include:
   - **SAST**: Semgrep for source code.
   - **SCA**: `scripts/scan-sbom.py` (OSV.dev) for declared dependencies, plus Grype (`anchore/scan-action`) for the built image.
   - **Signing**: Cosign for OCI artifacts.
4. **Automated Smoke Tests**: Add a `docker run --version` check for any new application runtime.

## Documentation
Documentation is stored in `docs/`. 
- **Mermaid Diagrams**: Store raw source in `docs/mermaid/`.
- **Rendered Images**: Store high-quality `.png` renders in `docs/images/`.

## Pull Requests
- Ensure all CI/CD workflows pass.
- Provide a clear explanation of which sovereign component you are adding or improving.
- Update the application matrix in `README.md` if applicable.
