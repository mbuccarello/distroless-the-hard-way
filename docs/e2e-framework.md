# Runtime Verification Framework (E2E)

## Overview

The runtime integrity of our distroless images is verified via an End-to-End (E2E) testing framework. This process ensures that the atomic foundation libraries (glibc, openssl, etc.) and language rumes (Java, Node.js, etc.) are not only correctly compiled but also functionally compatible in a production-identical, shell-less environment.

## Methodology

Our verification methodology follows a rigorous three-stage process:

1.  **Binary Provisioning**: The target distroless image is assembled using our zero-trust bootstrap extractor.
2.  **Artifact Injection**: A minimal, standardized "smoke test" application is compiled on a trusted SDK host and then injected into the scratch-based distroless container.
3.  **Functional Execution**: The container is executed without a shell, invoking the application entry point directly. A successful exit code (0) and specific stdout assertions prove the cryptographic and functional correctness of the underlying library ecosystem.

## Supported Runtime Matrix

The following table details the runtime environments and their corresponding verification logic located in the `E2E/` directory:

| Runtime | Test Application | Source Path | Verification Objective |
| :--- | :--- | :--- | :--- |
| **Node.js** | `index.js` | `E2E/nodejs/` | V8 engine execution & basic I/O |
| **Python 3** | `main.py` | `E2E/python3/` | Interpreter stability & standard library linkage |
| **Java** | `HelloOpensource.java` | `E2E/java/` | JVM initialization & glibc/libstdc++ compatibility |
| **.NET** | `HelloOpensource` | `E2E/dotnet/` | CoreCLR execution & native library resolution |
| **PHP** | `test.php` | `E2E/php/` | PHP engine execution & module loading |
| **Perl** | `test.pl` | `E2E/perl/` | Perl interpreter integrity |

## Architectural Isolation

By maintaining these tests in a dedicated `E2E/` directory, we decouple the verification logic from the build pipelines. This allows for independent auditing of the test artifacts and ensures that our distroless images remain unpolluted by development headers or build-time dependencies.

For detailed instructions on running these tests locally, refer to the individual pipeline guides in `docs/pipelines/`.
