# Sovereign Distroless: Operations, Maintenance & Testing

This document covers the Day-2 operations, versioning strategy, and testing framework for the Distroless ecosystem.

---

## 1. Lifecycle & Maintenance

### 1.1 Version Selection Policy
The project prioritizes stability and long-term support (LTS) for runtimes and core libraries:
- **Core Libraries**: Track the latest stable versions from Arch Linux repositories.
- **Runtimes**: Focus on LTS versions (e.g., Python 3.12/3.14, Node.js 22, .NET 8).
- **Pinning**: All versions are pinned in `stacks/*.yaml` to ensure reproducibility.

### 1.2 Patching Process
Security patches are applied through a weekly synchronization:
1. **Upstream Detection**: The engine checks for new versions of core dependencies.
2. **Rebuild Hierarchy**: A change in a foundation layer (e.g., `openssl`) triggers a full cascade rebuild of the entire fleet.
3. **Validation**: Every rebuild must pass the automated E2E smoke tests.

---

## 2. Testing & Verification

### 2.1 E2E Verification Framework
The project uses a dedicated, automated E2E testing pipeline:
- **Dedicated Workflow**: [`.github/workflows/distroless-e2e.yml`](file:///Users/michele.buccarello/distroless-the-hard-way/.github/workflows/distroless-e2e.yml) handles the validation of every built image.
- **Test Matrix**: Every language stack has a corresponding test script (e.g., `test.py`, `test.js`, `test.java`).
- **Logic**: Tests verify that the runtime can execute basic code, load core libraries (ABI check), and access the root trust store (SSL check).
- **Trigger**: The E2E tests are automatically triggered after every successful build in the `Bake Master` pipeline, but can also be run manually for verification.

### 2.2 Debugging Strategy
Since production images are shell-less, debugging is performed using the `:debug` variants:
- **Busybox**: Includes a minimal, non-privileged Busybox environment.
- **Ephemeral Debugging**: Use `docker run --rm -it <image>:debug /bin/sh` to inspect the filesystem and network state.

---

## 3. Local Development

To test a new stack or library locally:
1. **Generate**: Run `./distroless_engine.py --stack stacks/<name>.yaml`.
2. **Build**: Execute `docker buildx bake runtime`.
3. **Verify**: Use the `:debug` tag to inspect the resulting image.
