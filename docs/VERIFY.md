# Keyless Image Verification

All OCI artifacts and container images produced by the fleet build pipeline are cryptographically signed using **Sigstore/Cosign** through GitHub Actions OIDC identity. This ensures that the image is compiled directly from the source code in this repository within a secure, tracked environment, eliminating the need to manage static cryptographic keys.

---

## Prerequisites

To verify image signatures, install the **Cosign** CLI (version 2.0 or higher):

- **macOS (Homebrew)**:
  ```bash
  brew install cosign
  ```
- **Linux**:
  ```bash
  curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64"
  sudo mv cosign-linux-amd64 /usr/local/bin/cosign
  sudo chmod +x /usr/local/bin/cosign
  ```

---

## Verification Workflow

Cosign validates the image signature by confirming that:
1. The signature was issued by the trusted OIDC provider: `https://token.actions.githubusercontent.com`.
2. The signing identity (`--certificate-identity-regexp`) matches the designated workflows in this repository (`mbuccarello/distroless-the-hard-way`).

---

## Quick Verification Commands

### 1. Runtime Images (L4)
Final runtime application images (Python, PHP, Perl, Node.js, Go) are compiled via the main fleet build workflow `distroless-bake-master.yml`.

#### Python
```bash
cosign verify ghcr.io/mbuccarello/python-distroless:latest \
  --certificate-identity-regexp "https://github.com/mbuccarello/distroless-the-hard-way/.github/workflows/distroless-bake-master.yml@.*" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
```

#### PHP
```bash
cosign verify ghcr.io/mbuccarello/php-distroless:latest \
  --certificate-identity-regexp "https://github.com/mbuccarello/distroless-the-hard-way/.github/workflows/distroless-bake-master.yml@.*" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
```

#### Perl
```bash
cosign verify ghcr.io/mbuccarello/perl-distroless:latest \
  --certificate-identity-regexp "https://github.com/mbuccarello/distroless-the-hard-way/.github/workflows/distroless-bake-master.yml@.*" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
```

#### Node.js
```bash
cosign verify ghcr.io/mbuccarello/nodejs-distroless:latest \
  --certificate-identity-regexp "https://github.com/mbuccarello/distroless-the-hard-way/.github/workflows/distroless-bake-master.yml@.*" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
```

#### Go
```bash
cosign verify ghcr.io/mbuccarello/go-distroless:latest \
  --certificate-identity-regexp "https://github.com/mbuccarello/distroless-the-hard-way/.github/workflows/distroless-bake-master.yml@.*" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
```

---

### 2. Foundation Images (L1 - L3)
Intermediate base layers are compiled via their respective workflows.

#### L1: Static (`static.Dockerfile`)
```bash
cosign verify ghcr.io/mbuccarello/static:latest \
  --certificate-identity-regexp "https://github.com/mbuccarello/distroless-the-hard-way/.github/workflows/distroless-foundation-static.yml@.*" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
```

#### L2: Base (`base.Dockerfile`)
```bash
cosign verify ghcr.io/mbuccarello/base:latest \
  --certificate-identity-regexp "https://github.com/mbuccarello/distroless-the-hard-way/.github/workflows/distroless-foundation-base.yml@.*" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
```

#### L3: CC Layer (`cc.Dockerfile`)
```bash
cosign verify ghcr.io/mbuccarello/cc:latest \
  --certificate-identity-regexp "https://github.com/mbuccarello/distroless-the-hard-way/.github/workflows/distroless-foundation-cc.yml@.*" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
```

---

### 3. Debug Variants (`:debug`)
All images listed above have a corresponding `:debug` variant (which bundles the minimal Busybox diagnostic shell). The signing identities remain identical:

```bash
# Example verifying the Python debug variant
cosign verify ghcr.io/mbuccarello/python-distroless:debug \
  --certificate-identity-regexp "https://github.com/mbuccarello/distroless-the-hard-way/.github/workflows/distroless-bake-master.yml@.*" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
```

---

## Output Verification Log
A successful verification outputs a JSON block containing the certificate chain and displays confirmation messages matching the following pattern:

```text
Verification for ghcr.io/mbuccarello/python-distroless:latest --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - Existence of the claims in the transparency log was verified offline
  - The signatures were verified against the certificate
  - The code-signing certificate was verified using trusted certificate authority certificates
```
