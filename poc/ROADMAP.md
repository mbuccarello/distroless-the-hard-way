# Opensource-Distroless Roadmap

This document outlines the strategic progression from the current Python "Proof of Concept" orchestrator into a production-grade, enterprise-ready cryptographically sovereign build engine.

## Phase 1: Pipeline Security & Software Supply Chain
While Opensource-Distroless currently verifies cryptographic `sha256` hashes from upstream providers to guarantee origin authenticity, the compiler pipeline must ensure the ingested code itself is fundamentally secure.

- [ ] **SAST (Static Application Security Testing):** Integrate static analyzers (like Semgrep or SonarQube) directly into the `build.py` orchestrator. Before executing `make`, the engine will statically scan the C/C++ source code payloads natively for memory leaks, buffer overflows, or known malicious patterns.
- [ ] **SCA (Software Composition Analysis):** Introduce dependency vulnerability scanners natively to ensure that the specifically downloaded version (e.g., `glibc-2.39`) does not contain known CVEs before compilation begins.
- [ ] **Automated SBOM Generation:** Automatically generate deterministic Software Bill of Materials (SPDX/CycloneDX) JSON records dynamically during the blueprint build steps mapping every compiled binary, and attach them structurally to the resulting OCI manifest.

## Phase 2: Cryptographic Provenance & Determinism
To prove absolute trust, the compilation process must be mathematically repeatable and verifiable.

- [ ] **Reproducible Builds:** Inject `SOURCE_DATE_EPOCH` and uniform path flags into the GNU build sandboxes. This will strip all compile-time timestamps, ensuring that compiling the exact same blueprint twice produces the exact same zero-variance Docker Image SHA256 hash.
- [ ] **Sigstore / Cosign Integration:** Configure the orchestrator to dynamically cryptographically sign the exact `scratch` Docker image payload utilizing Sigstore infrastructure or an internal KMS immediately upon generation.

## Phase 3: Architectural Portability
Transition the orchestrator engine from relying on the local Docker Daemon ecosystem into a standalone, system-agnostic framework.

- [ ] **Multi-Architecture Blueprints:** Upgrade YAML logic to accept dynamic architecture variables (`${ARCH}`). The compiler will natively intercept whether it is running on `linux/amd64` or `linux/arm64` and adjust GNU compiler cross-compilation flags and OpenJDK URL downloads concurrently.
- [ ] **Golang Rewrite (`cmd/sovereignforge`):** Migrate `build.py` to a strictly compiled `sovereignforge` Go binary utilizing the `go-containerregistry` library. This eliminates the Python `venv` requirement and allows native programmatic manipulation of OCI blobs and manifests without requiring a local Docker daemon (`FROM scratch` workarounds).
