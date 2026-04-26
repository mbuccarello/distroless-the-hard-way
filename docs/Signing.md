# Specification: Cryptographic Artifact Signing

Every artifact and image within the Distroless The Hard Way ecosystem is cryptographically signed using Sigstore/Cosign to ensure end-to-end integrity.

---

## 1. Keyless Signing Architecture

The project utilizes OIDC-based keyless signing to eliminate the risks associated with static private key management.

- **Mechanism**: Sigstore Fulcio and Rekor.
- **Identity**: GitHub Actions OIDC tokens (`id-token: write`).
- **Validation**: Signatures are verifiable via `cosign verify` using the project's OIDC issuer and repository identity.

## 2. Cryptographic Bundle
Every image is accompanied by a cryptographic bundle that includes:
- **OCI Signature**: Proves the origin and integrity of the image bits.
- **SLSA Provenance**: Proves the integrity of the build process and environment.
- **SPDX SBOM**: Provides a verified bill-of-materials attached via `cosign attach sbom`.

## 3. Verification Gateways
Downstream assemblers verify the signatures of all intermediate Stage 2 payloads before ingestion, ensuring that only vetted and signed components enter the final product.

