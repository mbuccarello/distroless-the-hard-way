# Pipelines & Continuous Integration

**Distroless The Hard Way** utilizes a strictly sequential CI/CD pipeline orchestrated via GitHub Actions. This document details the **Tiered Pipeline Hierarchy**.

---

## 1. The Tiered Hierarchy

Our supply chain follows a linear cascading model. If a core component (e.g., `glibc` in the base layer) is updated, all downstream dependencies and runtime stacks must automatically rebuild to inherit the security patches.

![Pipeline Flow](images/pipeline_flow.png)

### The Workflows

1. **`distroless-foundation-static.yml` (L1)**
   - **Trigger**: Changes to `foundations/static.Dockerfile`.
   - **Role**: Assembles the minimal rootfs (certificates, tzdata, passwd).
   - **Output**: `ghcr.io/mbuccarello/static:latest`

2. **`distroless-foundation-base.yml` (L2)**
   - **Trigger**: Successful completion of the static workflow, or changes to `base.Dockerfile`.
   - **Role**: Compiles and injects the dynamic linker (`ld-linux`) and `libc.so.6`.
   - **Output**: `ghcr.io/mbuccarello/base:latest`

3. **`distroless-foundation-cc.yml` (L3)**
   - **Trigger**: Successful completion of the base workflow, or changes to `cc.Dockerfile`.
   - **Role**: Assembles the core C/C++ libraries (OpenSSL, Zlib, Libxcrypt).
   - **Output**: `ghcr.io/mbuccarello/cc:latest`

4. **`distroless-stack-runtime.yml` (L4)**
   - **Trigger**: Successful completion of the CC workflow, or changes to specific stack definitions (`stacks/*.yaml`).
   - **Role**: Uses the `engine.py` to assemble language runtimes (PHP, Perl, Python) from the CC foundation.
   - **Output**: The final runtime images (e.g., `ghcr.io/mbuccarello/php:latest`).

---

## 2. Supply Chain Security

Every step in the pipeline is hardened according to SLSA Level 3 principles:

- **Keyless Signing**: The pipelines utilize Sigstore's Cosign to cryptographically sign images using the GitHub OIDC identity.
- **Provenance Attestations**: Buildkit provenance attestations are pushed to the registry for every image layer.
- **Cache Isolation**: The tiered model ensures high cache utilization without compromising supply chain boundaries. Each step only pulls the validated output of the step before it.

---

## 3. End-to-End Verification

After a full fleet build, the `distroless-e2e-fleet.yml` workflow is triggered. This workflow performs "smoke tests" on every generated runtime image (e.g., executing `python3 -c "import urllib.request"`) to ensure the final images are operational and ABI-compatible.
