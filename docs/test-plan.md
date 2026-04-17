# Validation & Test Plan

"Distroless The Hard Way" is an educational repository enforcing a strictly decoupled, zero-trust cascade. You can validate the entire architecture using one of two methods: the **Automated Gateway**, or the **Manual Educational Walkthrough**.

Ensure you have enabled the `GITHUB_TOKEN` write permissions (see [Registry Authentication Setup](GHCR-Token.md)) before proceeding.

---

## Method 1: The Automated Gateway (The Easy Way)
For automated validation of the entire cryptographic dependency graph, we utilize a master Directed Acyclic Graph (DAG) orchestrator.

1. Navigate to the **Actions** tab in GitHub.
2. Select the `Distroless The Hard Way - E2E Orchestrator` workflow.
3. Click **Run workflow**.

The orchestrator will automatically construct everything chronologically:
* It spins up Pipeline 0 (Bootstrap)
* It fans out Stage 1 in parallel (glibc, openssl, zlib, tzdata)
* It waits for all Stage 1 results, merging them into Stage 2 (Base Assembly)
* It steps into Stage 3 (C++ Assembly)
* It fans out across the entire Test Matrix (Node.js, Python, Java, etc.) to prove runtime integrity.

---

## Method 2: Step-by-Step Compilation (The Educational Way)
To truly grasp the concept of compiling a zero-trust supply chain from scratch, you should ignore the automator and manually trace the dependency tree yourself.

#### 1. Stage 0: The Extractor Bootstrap
* **Target Workflow**: `Distroless The Hard Way - Bootstrap Builder`
* **Trigger**: Click **Run workflow** manually.
* **Validation**: This compiles our static extraction binary from source and pushes it to your `ghcr.io` namespace.

#### 2. Stage 1: Atomic Foundations
* **Target Workflows**: Manually trigger all four foundation pipelines:
  - `Opensource Distroless Build - glibc`
  - `Opensource Distroless Build - openssl`
  - `Opensource Distroless Build - zlib`
  - `Opensource Distroless Build - tzdata`
* **Validation**: Ensure all turn green to verify successful raw source compilation and SCA scanning.

#### 3. Stage 2: Base Assembly
* **Target Workflow**: `Opensource Distroless Assembler - base`
* **Trigger**: Click **Run workflow** if not automatically triggered by GitHub.
* **Validation**: Validate that Docker natively executed the `/tar` command safely from our bootstrap image without using `/bin/sh`. Ensure `malcontent` capability analysis passes.

#### 4. Stage 3 & Execution Verification (E2E)
Once the `base` image is built, compile the execution runtimes:

1. **Build the C++ Runtime**: Run `Opensource Distroless Build - gcc`
2. **Assemble the C++ Runtime**: Run `Opensource Distroless Assembler - cc`
3. **Run Validations**: Trigger any of the tests: (e.g., `Distroless The Hard Way - Test - Java`).

When these pipelines turn green, you have successfully proven that your native distroless environment can execute complex applications securely!
