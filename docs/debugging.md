[<- Back to Main README](../README.md)

# Debugging & Diagnostics Guide

This document outlines the standard procedures for diagnosing and fixing build failures, ABI mismatches, and runtime errors in the Opensource Distroless project.

## 1. Universal Local Debug Ecosystem

The project now provides a comprehensive **debug/ folder ecosystem** covering all layers of the 4-tier hierarchy.

- **Foundations**: `debug/base`, `debug/cc`.
- **Runtimes**: `debug/python3`, `debug/java`, `debug/nodejs`, `debug/dotnet`, `debug/php`, `debug/perl`, `debug/go`.

### Workflow for Local Fixes:
1.  **Navigate** to the relevant directory (e.g., `cd debug/python3`).
2.  **Modify** the `Dockerfile` to test configuration changes, compiler flags (`CFLAGS`), or linker flags (`LDFLAGS`).
3.  **Execute** `./reproduce.sh`. This script will:
    - Build the image locally on your machine.
    - **Payload Management**: For Java, .NET, and Node.js, it will automatically download the required binary payloads if missing.
    - **Sovereign Audit**: Automatically run `ldd` and `readelf` to verify library linkage and RPATH health.

## 2. The Smart Assembly Wrapper

We use [`scripts/assemble.sh`](file:///Users/michele.buccarello/distroless-the-hard-way/scripts/assemble.sh) as a mandatory wrapper for all compilation steps.

### Diagnostic Power:
- **Error Capturing**: In case of failure, it dumps the environment state and extracts critical errors from `config.log`.
- **Binary Audit**: It enforces checks for the **Hardened RPATH** (`-Wl,-rpath`).
- **Isolation**: It ensures the `DESTDIR` is correctly populated and isolated from the build sandbox.

## 3. High-Assurance Validation (Layer 3)

Functional verification is performed via the `app/` test suite.

- **SSL/TLS Handshakes**: Verified for every runtime using our sovereign CA bundle.
- **Dependency discovery**: Validated by importing native modules (e.g., `sqlite3` in Python, `mbstring` in PHP).
- **Security Check**: Images are scanned for non-root execution (`USER 65532`).

## 4. Common Failure Patterns

| Error | Root Cause | Solution |
| :--- | :--- | :--- |
| `Not found` (library) | Missing RPATH or missing L1.5 layer | Add `-Wl,-rpath,/usr/local/lib` to `LDFLAGS`. |
| `SSL_CERT_FILE` fail | Missing trust bundle | Verify `ca-certificates` is injected into the rootfs. |
| `cosign: not found` | Workflow permission | Add `Install Cosign` step and `id-token: write` permission. |
| `checksum mismatch` | Corrupted source | Update the `sha` in `build-runtime-foundations.yml`. |
