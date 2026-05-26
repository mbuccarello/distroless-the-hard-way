# Distroless Security: High-Assurance Supply Chain

This document defines the security architecture, compliance standards, and integrity verification processes of the **Distroless The Hard Way** project.

---

## 1. Cryptographic Integrity

### 1.1 Keyless Signing (Sigstore/Cosign)
Every image produced by the GitHub Actions fleet workflows is signed cryptographically using **Cosign** with GitHub's OIDC identity.
- **Verification**: Image provenance can be validated without managing static keys. Refer to **[docs/VERIFY.md](VERIFY.md)** for copy-pasteable commands for all fleet images.
  ```bash
  cosign verify ghcr.io/mbuccarello/python-distroless:latest \
    --certificate-identity-regexp "https://github.com/mbuccarello/distroless-the-hard-way/.github/workflows/distroless-bake-master.yml@.*" \
    --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
  ```

### 1.2 SLSA Level 3 Provenance
The build pipeline generates non-falsifiable **SLSA (Secure Supply Chain Levels for Software Artifacts) Level 3** build provenance attestations for every OCI image. This attestation provides:
- The source repository and precise commit SHA.
- Fleet engine parameters and build-time metadata.
- A cryptographically linked signature tied directly to the image digest.

---

## 2. Vulnerability Scanning & Scanner Limitations

### 2.1 Why Standard Container Scanners Fail (Trivy/Grype/Snyk Limitations)
Traditional OCI container image vulnerability scanners (such as **Trivy**, **Grype**, **Snyk**, or **Prisma**) are designed for standard operating system distributions and rely on specific system indicators to catalog installed libraries. In our source-compiled distroless architecture, these indicators **do not exist**, rendering standard scanners blind and prone to false negatives (reporting zero vulnerabilities even if outdated libraries are present).

#### System Requirements for Standard Scanners:
1. **OS Detection**: Scanners parse `/etc/os-release` or `/usr/lib/os-release` to identify the distribution family (e.g., Debian, Alpine, RHEL) and match vulnerabilities against the corresponding OS security tracker.
2. **Package Manager Databases**: Scanners parse standard package manager databases to discover installed software:
   - `/var/lib/dpkg/status` (Debian/Ubuntu)
   - `/lib/apk/db/installed` (Alpine)
   - RPM database `/var/lib/rpm/` (Fedora/RHEL/SUSE)
3. **Language Packages Metadata**: Scanners look for language runtime manifests (e.g., `package.json` for Node, `requirements.txt` or `dist-info` directories for Python).

**Project Context**:
We compile all foundational dependencies (e.g., zlib, OpenSSL, libxml2, curl, SQLite) from upstream source tarballs and copy the resulting binaries and shared libraries directly into `/usr/lib` and `/usr/lib64`. Because there is no host OS package database, standard scanners fail to identify the package inventory and report a **false sense of security** by defaulting to zero findings.
*(Red Hat Hummingbird resolved this limitation by collaborating directly with vulnerability database vendors to catalog custom RPM-based layers; a pure source-compiled architecture requires a different approach).*

---

### 2.2 Stack-Based Vulnerability Auditing (OSV.dev API)
To ensure high-assurance auditing, we bypass filesystem-based scanner heuristics and leverage the exact build specifications.

The validation pipeline utilizes the custom tool **[scripts/scan-sbom.py](../scripts/scan-sbom.py)** to execute the following steps:
1. Parses the language stack definition files (`stacks/*.yaml`), which serve as the single source of truth for all source-compiled libraries.
2. Extracts the exact package names and pinned upstream versions (e.g., `openssl 3.4.0`, `zlib 1.3.1`).
3. Queries Google's **OSV.dev** (Open Source Vulnerability) database API (`https://api.osv.dev/v1/query`) via direct, automated HTTPS requests.
4. Generates a deterministic security report detailing all active CVEs with zero false negatives.

This ensures precise, robust security gating that can be integrated directly into the CI/CD workflow.

---

## 3. Integrity Verification & Static Analysis

### 3.1 Capability Analysis (Malcontent) — *Roadmap*
Validating compiled binary integrity via **Chainguard Malcontent** (to detect unexpected dynamic capabilities, suspicious syscalls, or malicious compilation vectors) is a planned roadmap capability. This check will be integrated as a post-compilation gating step to verify that the build environment has not been compromised.

### 3.2 Static Analysis (Semgrep & Scorecard)
- **Semgrep**: Used to scan generated Dockerfiles and Python engine orchestration code for security misconfigurations.
- **OpenSSF Scorecard**: Evaluates the repository continuously against open-source security best practices (e.g., branch protection, pinned build actions).

---

## 4. Registry Authentication (GHCR)

CI/CD publishing and consumption of OCI packages in the GitHub Container Registry leverages the automatic, short-lived `GITHUB_TOKEN` with elevated permissions:
- **Configuration**: Settings -> Actions -> General -> Workflow permissions -> **Read and write permissions**.
- **Security Control**: Prevents the use of long-lived Personal Access Tokens (PATs) and enforces the principle of least privilege.
