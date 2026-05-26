# Developer Utility & Automation Reference Guide

This document defines the parameters, operational workflows, inputs, and outputs for all automation tools located under the `scripts/` directory.

---

## 1. assemble.sh (Compilation & Audit Harness)

A bash utility harness executed during intermediate Atom layers to compile packages safely and audit the dynamic dependencies of the compiled binaries.

*   **Syntax**: `./scripts/assemble.sh <name> <command...>`
*   **Parameters**:
    *   `<name>`: The unique identifier of the Atom package (e.g., `openssl`).
    *   `<command...>`: The full compilation command string (e.g., `make -j2 && make install`).
*   **Workflow Behavior**:
    *   Executes the command and redirects output in real-time to `/tmp/diag/build.log`.
    *   On failure, dumps the system environment and prints the last 200 lines of `config.log` or `config.sh` for diagnostic profiling.
    *   Audits `/rootfs` (or the destination path) to ensure compilation artifacts were successfully installed.
    *   Runs a binary audit (`ldd`) and dynamic lookup check (`readelf -d`) to verify that the RPATH includes standard high-assurance target directories.

---

## 2. scan-sbom.py (OSV Security Scanner)

Performs an automated Software Bill of Materials (SBOM) security check against the Open Source Vulnerabilities (OSV.dev) API.

*   **Syntax**: `python3 scripts/scan-sbom.py <path_to_stack_yaml_or_dir>`
*   **Parameters**:
    *   `<path_to_stack_yaml_or_dir>`: Path to a specific stack YAML file (e.g., `stacks/php.yaml`) or a directory containing multiple stack manifests.
*   **Workflow Behavior**:
    *   Parses the stack configuration to extract all defined packages and pinned versions.
    *   Queries the OSV.dev query API (`https://api.osv.dev/v1/query`) sequentially.
    *   Prints CVE indicators, vulnerability summaries, and security status.
    *   Exits with a status code of `0` (reporting warnings without breaking local pipelines if issues are identified).

---

## 3. generate-foundations.py (Arch-to-Bake Sync)

A transient translation tool used by developers to parse Arch Linux packaging metadata and output dynamic Docker Bake (HCL) targets.

*   **Syntax**: `python3 scripts/generate-foundations.py <pkgname>`
*   **Parameters**:
    *   `<pkgname>`: The name of the package as declared in the Arch Linux packaging repositories.
*   **Workflow Behavior**:
    *   Fetches the raw PKGBUILD dynamically from `gitlab.archlinux.org`.
    *   Extracts dependencies (`depends`) and common configure parameters.
    *   Prints a structured, standard HCL `target` block output ready to be copied into HCL configurations.

---

## 4. image-report.py (OCI Metadata Report Compiler)

Compiles a real-time status and size report across all OCI container stacks.

*   **Syntax**: `python3 scripts/image-report.py`
*   **Parameters**: None.
*   **Workflow Behavior**:
    *   Checks for the presence of local container runtimes (`docker` or `podman`).
    *   Queries image metadata (size, layer counts, entrypoints, user context) via `inspect`.
    *   Falls back to historical baseline figures if the images are not built locally.
    *   Overwrites the markdown file at `docs/IMAGE_REPORT.md` with structured technical reports.
