# Day 2 Operations: Project Maintenance Guide

This document defines the routine maintenance tasks required to ensure the "Distroless The Hard Way" project remains secure, up-to-date, and operational.

---

## 1. Mirror Management (Internal Cache)

To avoid external rate limits (Docker Hub/AWS ECR), the project uses an internal cache of the Alpine base image in GHCR.

### How to Refresh the Mirror
If you need to update the base Alpine image (e.g., for security patches or a new Alpine release):
1. Navigate to the **Actions** tab in GitHub.
2. Select the workflow: **"Opensource Distroless Mirror - Base Alpine"**.
3. Click **"Run workflow"**.
4. Once completed, all subsequent builds will automatically use the new cached image.

---

## 2. Integrity & Checksum Updates

The foundation build process uses hardcoded SHA256 hashes to ensure bit-level reproducibility (SLSA compliance).

### When to Update
- If an upstream project (e.g., Glibc, OpenSSL) releases a new point version.
- If an upstream project regenerates a source archive with the same version name (rare, but happens).

### How to Verify and Calculate SHAs
To ensure the supply chain remains "bit-perfect," follow this procedure when updating a component:
1. **Identify Upstream URL**: Locate the canonical source URL (e.g., IANA for tzdata, GNU for glibc).
2. **Download Artifact**:
   ```bash
   curl -L <URL> -o /tmp/component.tar.gz
   ```
3. **Calculate Hash**:
   ```bash
   # Use shasum for macOS/Linux
   shasum -a 256 /tmp/component.tar.gz | cut -d' ' -f1
   ```
4. **Cross-Verify**: If the upstream project provides a `.sig` or `.asc` file (e.g., GNU projects), verify it with GPG before trusting the hash.
   ```bash
   # Example for GNU projects
   gpg --verify component.tar.gz.sig
   ```
5. **Update Workflow**: Update the `echo "<HASH> workspace/..." | sha256sum -c -` line in the corresponding build YAML.

---

## 3. Security Patching (Hardening)

When a SAST (Semgrep) or SCA (Trivy) scan reveals a vulnerability in an upstream component, the project follows the decoupled hardening track.

### The Patching Workflow
1. Identify the repair patch from upstream security advisories.
2. Save the `.patch` file in `patches/<component>/`.
3. Trigger the **"Opensource Distroless Hardener"** workflow manually via GitHub Actions.
4. Verify that the generated image has the `-hardened` suffix in GHCR.

---

## 4. Pipeline Cleanup

Over time, GitHub Actions history can become cluttered, making it hard to debug failures.

### Purging Build Logs
To clear all previous workflow runs and start with a "clean slate," use the following command from a terminal with `gh` installed:

```bash
gh run list --limit 100 --json databaseId --jq ".[].databaseId" | xargs -I{} gh run delete {}
```

---

## 5. SLSA Attestation Verification

Every OCI artifact produced by this pipeline is signed with **Sigstore Cosign** and has a **SLSA Level 3** provenance record.

### How to Verify an Image
Use the `cosign` CLI to verify both the signature and the provenance:

```bash
# Verify the signature
cosign verify ghcr.io/<owner>/artifacts-<component>:latest --certificate-identity-regexp "https://github.com/mbuccarello/distroless-the-hard-way/.github/workflows/build-.*.yml@refs/heads/main" --certificate-oidc-issuer "https://token.actions.githubusercontent.com"

# Verify the SLSA provenance
gh attestation verify ghcr.io/<owner>/artifacts-<component>:latest --owner mbuccarello
```

---

## 6. Build Environment Constraints

### GNU C Library (Glibc)
> [!IMPORTANT]
> **Host Incompatibility**: Never attempt to build Glibc on an Alpine (musl-based) host. The musl system headers will conflict with Glibc headers, causing macro redefinitions (e.g., `PAGE_SIZE`) that fail the build.
> - **Requirement**: Always use a Glibc-native sandbox (e.g., `fedora`, `debian`, `ubuntu`).

### Timezone Data (tzdata)
> [!NOTE]
> **Dual-Source Requirement**: Version 2024b and later require merging two upstream tarballs: `tzcodeYYYYx.tar.gz` (logic) and `tzdataYYYYx.tar.gz` (definitions). Building from data-only packages will fail.

---

> [!IMPORTANT]
> **ABI Stability**: When applying patches to `glibc` or `openssl`, always verify that you are not breaking the Application Binary Interface (ABI), as these libraries are shared by all downstream language runtimes.
