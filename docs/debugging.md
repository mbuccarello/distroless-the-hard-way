[<- Back to Main README](../README.md)

# Debugging & Diagnostics Guide

This document outlines the standard procedures for diagnosing and fixing build failures, ABI mismatches, and runtime errors in the Opensource Distroless project.

## 1. Local Reproduction
To avoid long feedback loops in CI, use the localized debug environments.

- **Location**: `debug/<runtime-name>/` (e.g., `debug/php/`)
- **Workflow**:
  1. Modify the `Dockerfile` in the debug directory to test specific configuration flags or library versions.
  2. Run `./reproduce.sh`. This script will:
     - Build the image locally.
     - Capture the full build log to `build.log`.
     - Perform an immediate `ldd` and `readelf` audit on the resulting binary.
  3. Monitor progress: `tail -f build.log`.

## 2. The Smart Assembly Wrapper
We use [`scripts/assemble.sh`](file:///Users/michele.buccarello/distroless-the-hard-way/scripts/assemble.sh) as a mandatory wrapper for all compilation steps.

### What it does:
- **Error Capturing**: If a command fails, it automatically dumps the environment variables and the relevant sections of `config.log`.
- **Pre-flight Checks**: It verifies that `/rootfs` is not empty after `make install`.
- **Binary Audit**: It runs `ldd` and `readelf -d` on the produced binary to verify:
  - **RPATH**: Must include `/usr/local/lib` and `/artifacts/lib`.
  - **Shared Links**: No host-OS libraries should be linked.

### Usage in Dockerfile:
```dockerfile
COPY scripts/assemble.sh /usr/local/bin/assemble
RUN assemble <component-name> "./configure --prefix=/usr/local && make"
```

## 3. Atomic Smoke Testing
Functional verification is performed using scripts in the `app/` directory.

- **Purpose**: Verify ABI compatibility (e.g., OpenSSL handshakes, XML parsing, SQLite connectivity).
- **Execution**:
  ```bash
  docker run --rm -v $(pwd)/app:/app <image-name> /app/test.<ext>
  ```
- **CI Enforcement**: If this test fails, the GitHub Action will terminate immediately and the image will **not** be signed or promoted.

## 4. GitHub Actions Troubleshooting
If a build fails in GitHub Actions:

1. **Check the `Assemble` step output**: Look for the `--- CONFIG.LOG ANALYSIS ---` section provided by `assemble.sh`.
2. **Review SBOM/Trivy**: If the build fails at the security gate, check the Trivy scan output for CRITICAL/HIGH vulnerabilities.
3. **Cosign Errors**: If signing fails, verify that the `id-token: write` permission is present in the workflow.

## 5. Common Issues & Solutions
- **ELFCLASS32 Error**: Occurs when a 64-bit binary tries to link against a 32-bit library. Fix: Ensure all libraries are sourced from the same architecture (check `lib` vs `lib64`).
- **Missing Library at Runtime**: The binary cannot find a sovereign library. Fix: Inject `-Wl,-rpath,/usr/local/lib` into `LDFLAGS`.
- **SSL Certificate Failure**: The runtime cannot verify HTTPS connections. Fix: Ensure the `ca-certificates.crt` is injected into `/etc/ssl/certs/` and the `SSL_CERT_FILE` env var is set.
