# Specification: SLSA Level 3 Provenance

Distroless The Hard Way implements Supply-chain Levels for Software Artifacts (SLSA) Level 3 to provide non-falsifiable build attestations for every OCI image.

---

## 1. Compliance Logic

The system utilizes the `actions/attest-build-provenance` framework to mathematically link final artifacts to their originating source code and CI environment.

### Non-Falsifiability
- **Platform Integrity**: Attestations are generated within the GitHub Actions trusted execution environment.
- **Identity Isolation**: Build identities are tied to the OIDC identity of the `distroless-the-hard-way` repository.

## 2. Implementation Strategy

Every Stage 2 (Foundation) and Stage 3 (Assembler) workflow includes a provenance generation task:
1. **Digest Capture**: The SHA-256 digest of the pushed OCI image is captured.
2. **Attestation Generation**: The digest is signed and bundled with a predicate describing the build steps and parameters.
3. **Registry Publication**: The attestation is published to GHCR alongside the image.

