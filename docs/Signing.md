# Cryptographic Signing (Keyless)

## Supply Chain Signatures
Every intermediate artifact AND final assembled base image in "Distroless The Hard Way" is cryptographically signed using **Cosign** (part of the Sigstore project).

## Where Are The Private Keys?
You will not find any long-lived Private/Public keys stored in the GitHub Secrets of this repository. **This is a feature, not a missing component.**

We utilize **OIDC Keyless Signing**. 

## How It Works
1. When GitHub Actions runs, it is granted an ephemeral OpenID Connect (OIDC) token (`permissions: id-token: write`).
2. The Action invokes `cosign sign --yes ghcr.io/repository/image`.
3. Cosign requests an ephemeral, short-lived certificate from the Sigstore Fulcio Certificate Authority.
4. Fulcio verifies the GitHub Actions OIDC token (proving mathematically that "this exact GitHub repository, at this exact commit, triggered this pipeline").
5. The image is signed with the ephemeral cert.
6. The signature and the certificate are published to Rekor (an immutable public transparency log).
7. The private key used for that signature is then immediately destroyed from memory.

By using Keyless signing, we eliminate the immense security risk of a developer's private key being leaked or stolen, guaranteeing that every image was exclusively built through our locked-down CI pipelines.
