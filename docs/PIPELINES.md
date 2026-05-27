# Pipelines & Continuous Integration

**Distroless The Hard Way** utilizes a strictly sequential CI/CD pipeline orchestrated via GitHub Actions. This document details the **Tiered Pipeline Hierarchy**.

---

## 1. The Tiered Hierarchy

Our supply chain follows a linear cascading model. If a core component (e.g., `glibc` in the base layer) is updated, all downstream dependencies and runtime stacks must automatically rebuild to inherit the security patches.

![Pipeline Flow](images/pipeline_flow.png)

### The Workflows

1. **`distroless-foundation-static.yml` (L1)**
   - **Trigger**: Changes to `foundations/static.Dockerfile`.
   - **Role**: Assembles the initial minimal `/` rootfs layout skeleton (timezone database, standard user files, empty FHS placeholders).
   - **Output**: `ghcr.io/mbuccarello/static:latest`

2. **`distroless-foundation-base.yml` (L2)**
   - **Trigger**: Successful completion of the L1 workflow, or changes to `foundations/base.Dockerfile`.
   - **Role**: Extracts glibc dynamic linker and runtime libraries (`ld-linux`, `libc.so.6`) and preserves FHS filesystem root symlinks.
   - **Output**: `ghcr.io/mbuccarello/base:latest`

3. **`distroless-foundation-cc.yml` (L3)**
   - **Trigger**: Successful completion of the L2 workflow, or changes to `foundations/cc.Dockerfile`.
   - **Role**: Orchestrates compiling dynamic C/C++ libraries (OpenSSL, Zlib, Libxcrypt) required for runtime dynamic linkages.
   - **Output**: `ghcr.io/mbuccarello/cc:latest`

4. **`distroless-stack-runtime.yml` (L4)**
   - **Trigger**: Successful completion of the L3 workflow, or manual dispatch.
   - **Role**: Uses the build engine (`engine/engine.py`) to resolve dependencies and compiles/injects targeted dynamic language stacks (Python, PHP, Perl).
   - **Output**: Core language stack OCI images (e.g., `ghcr.io/mbuccarello/python-distroless:latest`).

5. **`distroless-fleet-build.yml` (Fleet Orchestration)**
   - **Trigger**: Scheduled weekly cron (Sundays at midnight) or manual dispatch.
   - **Role**: Automatically discovers all stack configurations (`stacks/*.yaml`) and spawns concurrent matrix builders executing parallelized assemblies.
   - **Output**: Re-builds and publishes the entire active language container fleet to GHCR.

6. **`distroless-bake-master.yml` (Master Compilation Core)**
   - **Trigger**: Reusable workflow caller (`workflow_call`).
   - **Role**: Central build engine orchestrating source-code compilations, dynamic Docker Bake operations, CycloneDX SBOM harvesting (via Syft), CVE sweeps (via Grype), and keyless OIDC Cosign signatures.
   - **Output**: Standard and `:debug` container tags, complete with cryptographic provenance attestations.

7. **`distroless-e2e-fleet.yml` (E2E Verification - Full Fleet)**
   - **Trigger**: Sequential launch upon successful completion of the "Distroless Full Fleet Build" workflow.
   - **Role**: Executes language-specific smoke tests dynamically across all compiled images using validation scripts inside `/app/`.
   - **Output**: Test validation reports confirming zero dynamic loader or ABI execution faults.

8. **`distroless-e2e.yml` (E2E Verification - Single-Stack)**
   - **Trigger**: Manual dispatch or workflow caller.
   - **Role**: Executes targeted smoke testing on a specific chosen language stack and image tag tag for rapid development verification.
   - **Output**: Stdin and stdout execution logs of the testing app inside the runtime environment.

---

## 2. Supply Chain Security

Every step in the pipeline is hardened according to SLSA Level 3 principles:

- **Keyless Signing**: The pipelines utilize Sigstore's Cosign to cryptographically sign images using the GitHub OIDC identity.
- **Provenance Attestations**: Buildkit provenance attestations are pushed to the registry for every image layer.
- **Cache Isolation**: The tiered model ensures high cache utilization without compromising supply chain boundaries. Each step only pulls the validated output of the step before it.

---

## 3. End-to-End Verification

After a full fleet build, the `distroless-e2e-fleet.yml` workflow is triggered. This workflow performs "smoke tests" on every generated runtime image (e.g., executing `python3 -c "import urllib.request"`) to ensure the final images are operational and ABI-compatible.
