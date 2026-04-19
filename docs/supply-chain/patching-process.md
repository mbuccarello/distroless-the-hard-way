# Security Patching Process

This document defines the formal process for identifying, acquiring, and applying security patches to the core components of the "Distroless The Hard Way" project. 

In a high-assurance supply chain, we distinguish between **Vendor Baseline** (upstream code) and **Project Hardening** (our modifications to address security vulnerabilities).

---

## 1. Vulnerability Discovery

Vulnerabilities enter the project lifecycle through two primary channels:
- **SAST (Semgrep)**: Identifies coding patterns in the source code (e.g., buffer overflows, unsafe memory management).
- **SCA/SBOM (Trivy)**: Identifies known CVEs mapped to the component versions used in our foundations.

Findings from the standard `build-*.yml` pipelines serve as the trigger for the patching process.

## 2. Patch Acquisition (The "Hard Way")

When a vulnerability is identified, a project maintainer must follow these steps to source a remediation:

1. **Upstream Research**: Check the official project security advisories (e.g., OpenSSL Security Advisories, GLIBC Wiki, GNU Security).
2. **Patch Identification**: Locate the specific Git commit or `.patch` file that remediates the CVE.
    - *Example*: For GLIBC, security patches are often backported to specific branches (e.g., `release/2.39/master`).
3. **Verification**: 
    - Verify the patch source (must be from the official project repository).
    - If a standalone `.patch` file is provided, verify its PGP signature if available.
    - Compute the SHA256 of the patch file for inclusion in our project's integrity records.

## 3. Ingestion and In-Repo Storage

The project uses a structured directory for managing the hardening state:

```text
patches/
└── <component>/
    ├── CVE-YYYY-XXXX.patch
    └── fix-audit-finding.patch
```

- Create a subdirectory named after the component (e.g., `patches/glibc/`).
- Drop the `.patch` file into this directory.
- The patch MUST be in a format compatible with `patch -p1`.

## 4. Hardening Execution (Decoupled Track)

Unlike standard builds, patching is **EXPLICIT and DECOUPLED**.

1. **Triggering**: Go to the **Actions** tab and select the `Opensource Distroless Hardener` workflow.
2. **Parameters**: Select the component (e.g., `glibc`) and initiate the run.
3. **Automated Steps**:
   - The workflow downloads the vendor source code.
   - It iterates through `patches/<component>/*.patch` and applies them using the `patch` utility.
   - It performs a **Hardened SAST Scan** where findings are no longer ignored (exit code 1 if the patch failed to remediate the high-severity finding).
4. **Publishing**: The result is pushed to GHCR with a `-hardened` suffix to prevent confusion with the vanilla vendor artifact.

## 5. Verification & Final Assembly

Once the hardened artifact is available:
1. **Validation**: Check the generated SBOM to ensure the patch is tracked in the build metadata.
2. **Integration**: Update the `assemble-base.yml` or downstream orchestrators to consume the `latest-hardened` tag instead of `latest`.

---

> [!IMPORTANT]
> **ABI Stability Warning**: Always ensure that applied security patches do not break ABI compatibility (Application Binary Interface), as foundation components like `glibc` are shared dependencies for the entire OCI image.
