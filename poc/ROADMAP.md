# Distroless-The-Hard-Way Roadmap

This document outlines the strategic progression from the current Python "Proof of Concept" orchestrator into a production-grade, enterprise-ready cryptographically sovereign build engine.

> Items below reflect the state of `poc/build.py`, the original PoC orchestrator. Several have since shipped in the production `engine/engine.py` pipeline and are checked off with a pointer to where they landed.

## Phase 1: Pipeline Security & Software Supply Chain
While Distroless-The-Hard-Way currently verifies cryptographic `sha256` hashes from upstream providers to guarantee origin authenticity, the compiler pipeline must ensure the ingested code itself is fundamentally secure.

- [ ] **SAST (Static Application Security Testing):** Integrate static analyzers (like Semgrep or SonarQube) directly into the `build.py` orchestrator. Before executing `make`, the engine will statically scan the C/C++ source code payloads natively for memory leaks, buffer overflows, or known malicious patterns.
- [x] **SCA (Software Composition Analysis):** Implemented as `scripts/scan-sbom.py`, which queries the OSV.dev API against each stack's declared dependency versions to flag known CVEs.
- [x] **Automated SBOM Generation:** Implemented in CI via `anchore/sbom-action` in `.github/workflows/distroless-bake-master.yml`, producing an SPDX/CycloneDX artifact per stack build.

## Phase 2: Cryptographic Provenance & Determinism
To prove absolute trust, the compilation process must be mathematically repeatable and verifiable.

- [ ] **Reproducible Builds:** Inject `SOURCE_DATE_EPOCH` and uniform path flags into the GNU build sandboxes. This will strip all compile-time timestamps, ensuring that compiling the exact same blueprint twice produces the exact same zero-variance Docker Image SHA256 hash.
- [x] **Sigstore / Cosign Integration:** Every image and Atom produced by the fleet pipeline is signed keylessly via Cosign/GitHub OIDC — see [`docs/VERIFY.md`](../docs/VERIFY.md) and [`docs/SECURITY.md`](../docs/SECURITY.md).

## Phase 3: Architectural Portability
Transition the orchestrator engine from relying on the local Docker Daemon ecosystem into a standalone, system-agnostic framework.

- [ ] **Multi-Architecture Blueprints:** Upgrade YAML logic to accept dynamic architecture variables (`${ARCH}`). The compiler will natively intercept whether it is running on `linux/amd64` or `linux/arm64` and adjust GNU compiler cross-compilation flags and OpenJDK URL downloads concurrently.
- [ ] **Golang Rewrite (`cmd/sovereignforge`):** Migrate `build.py` to a strictly compiled `sovereignforge` Go binary utilizing the `go-containerregistry` library. This eliminates the Python `venv` requirement and allows native programmatic manipulation of OCI blobs and manifests without requiring a local Docker daemon (`FROM scratch` workarounds).
