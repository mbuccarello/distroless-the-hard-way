# Distroless Debugging Environments

This directory contains localized, self-contained debugging environments for each component and runtime in the Opensource Distroless stack.

## Purpose

The CI/CD pipeline on GitHub Actions is highly optimized but can have long feedback loops (especially for source-built runtimes like PHP or Python which take minutes or hours to compile). When a build fails in CI (e.g., missing dependencies, ABI mismatches, RPATH issues), these debug folders allow you to rapidly iterate and test fixes locally.

## Structure

Each runtime has its own dedicated folder containing:

1. **`Dockerfile`**: A specialized version of the CI build process. It mirrors the exact steps taken in GitHub Actions but is designed to be built locally on your machine.
2. **`reproduce.sh`**: A utility script that automates the building and testing of the image.

## Usage

To debug a specific runtime (e.g., Python 3):

1. Navigate to the specific debug folder:
   ```bash
   cd debug/python3
   ```
2. Modify the `Dockerfile` to test your fix (e.g., add a missing library, change `LDFLAGS`, adjust a `./configure` flag).
3. Run the reproduction script:
   ```bash
   ./reproduce.sh
   ```

### What `reproduce.sh` does:
- Builds the Docker image locally (tagged as `<runtime>-debug`).
- Runs a basic functional test (e.g., `python3 --version`).
- Audits the linked libraries using `ldd`.
- Inspects the RPATH using `readelf` to ensure no host-OS leakage occurs and the sovereign directories (`/artifacts/lib`, `/usr/local/lib`) are correctly prioritized.

## Best Practices

- **Mirror CI**: Keep the debug `Dockerfile` as close to the `.github/workflows/assemble-<runtime>.yml` file as possible. When you find a fix locally, copy the exact lines back into the YAML workflow.
- **Isolate Changes**: Use these environments to isolate problems. If `cc` fails, debug `cc` first before moving to `java` or `nodejs`.
