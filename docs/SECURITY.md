# Distroless Security: High-Assurance Supply Chain

This document defines the security architecture, compliance standards, and integrity verification processes of the **Distroless The Hard Way** project.

---

## 1. Cryptographic Integrity

### 1.1 Keyless Signing (Sigstore/Cosign)
Every image produced by the engine is signed using **Cosign** with GitHub's OIDC identity.
- **Verification**: Images can be verified without managing static keys:
  ```bash
  cosign verify ghcr.io/michelebuccarello/python-distroless:latest \
    --certificate-identity-regexp "https://github.com/mbuccarello/distroless-the-hard-way/.github/workflows/distroless-bake-master.yml@.*" \
    --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
  ```

### 1.2 SLSA Level 3 Provenance
The project generates **SLSA Level 3** build provenance for every artifact. This provides a non-falsifiable record of the build process, including:
- Source repository and commit SHA.
- Build platform (GitHub Actions).
- Build parameters and engine metadata.
- Cryptographically linked image digest.

---

## 2. Integrity Verification (Gating)

### 2.1 Capability Analysis (Malcontent)
The integrity of compiled binaries is verified using **Chainguard Malcontent** to detect unexpected capabilities, syscalls, or malicious indicators. This ensures that the build strategy has not been bypassed by unexpected build-time behaviors.

### 2.2 Static Analysis (Semgrep & Scorecard)
- **Semgrep**: Used to scan Dockerfiles and Python engine code for security misconfigurations.
- **OpenSSF Scorecard**: Automated evaluation of repository security best practices (e.g., branch protection, pinned dependencies).

---

## 3. Registry Authentication (GHCR)

To publish or pull images from the GitHub Container Registry in CI/CD, the project leverages the `GITHUB_TOKEN` with elevated permissions:
- **Settings**: Actions -> General -> Workflow permissions -> **Read and write permissions**.
- **Logic**: Prevents the need for long-lived Personal Access Tokens (PATs) and follows the principle of least privilege.
