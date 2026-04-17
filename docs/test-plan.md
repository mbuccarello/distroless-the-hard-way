# Distroless The Hard Way: Validation & Test Plan

If you have forked this repository to your own GitHub account and have enabled the `GITHUB_TOKEN` write permissions (see [Registry Authentication Setup](GHCR-Token.md)), you can validate the entire architecture from scratch.

Because this architecture enforces a strictly decoupled, zero-trust cascade, you cannot simply trigger the final pipeline. You must build the dependencies in chronological order.

## 1. Stage 0: The Extractor Bootstrap
* **Action**: Navigate to the **Actions** tab in GitHub.
* **Target Workflow**: `Distroless The Hard Way - Bootstrap Builder`
* **Trigger**: Click **Run workflow**.
* **Validation**: Wait for the job to complete successfully. This compiles our zero-trust static extraction binary from source and pushes it to your personal `ghcr.io` namespace.

## 2. Stage 1: Atomic Foundations
* **Action**: From the Actions tab, you must trigger all four foundation pipelines individually into the system.
* **Target Workflows**:
  - `Opensource Distroless Build - glibc`
  - `Opensource Distroless Build - openssl`
  - `Opensource Distroless Build - zlib`
  - `Opensource Distroless Build - tzdata`
* **Validation**: Ensure all four turn green. This verifies that `Semgrep` successfully audited the raw source and `Trivy` scanned the resulting artifacts before signing them.

## 3. Stage 2: Base Assembly
* **Action**: The base assembler dynamically watches the foundations. It *may* trigger automatically when the four prior steps finish. If not, trigger it manually.
* **Target Workflow**: `Opensource Distroless Assembler - base`
* **Trigger**: Click **Run workflow** if it hasn't started.
* **Validation**: Watch the logs. Validate that Docker natively executed the `/tar` command via the Exec-form without using `/bin/sh` or `alpine`. Ensure `malcontent` completes the capability analysis without throwing critical errors.

## 4. Stage 3 & Execution Verification (E2E)
Once the `base` image is built, you can compile the execution runtimes and test them using our End-to-End framework.

1. **Build the C++ Runtime**: Run the `Opensource Distroless Build - gcc` workflow.
2. **Assemble the C++ Runtime**: Run the `Opensource Distroless Assembler - cc` workflow.
3. **Run Validations**: Finally, run any of the application runtime tests (e.g., `Distroless The Hard Way - Test - Java`, `Test - Nodejs`, `Test - Python3`).

When these E2E pipelines turn green, you have successfully proven that your distroless environment can compile and execute complex applications natively using the pure zero-trust layers you just mathematically generated from scratch!
