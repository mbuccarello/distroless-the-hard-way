> [!NOTE]
> **The Hard Way:** This is an educational tutorial pipeline. Every single step here performs compilation from raw source. We do not use Debian extraction.

# Opensource Distroless E2E Verification Framework

The Opensource-Distroless project implements a rigorous **End-to-End (E2E) Verification Framework** to ensure the technical integrity of every produced runtime image. Unlike simple smoke tests, our E2E suite validates critical system-level components that were natively compiled from source.

## Verification Objectives

Every E2E test application (Dotnet, Java, Node.js, etc.) is designed to prove two critical security and functionality points:

### 1. SSL/TLS Integrity (`openssl`)
- **Reasoning**: We do not trust host-provided OpenSSL binaries. Every runtime must prove it can perform a secure, verified HTTPS handshake using our Opensource Distroless-compiled OpenSSL layer.
- **Test**: The application performs an `HTTPS GET` request to `https://www.google.com`.
- **Proof**: Success proves that root CA certificates, cryptographic algorithms, and the OpenSSL shared library are correctly linked and functional.

### 2. Timezone Resolution (`tzdata`)
- **Reasoning**: Accurate time is critical for security logging and JWT validation.
- **Test**: The application resolves the `Europe/Rome` timezone and displays the current regional time.
- **Proof**: Success proves that our Opensource Distroless-compiled `tzdata` database is correctly mounted and readable by the high-level runtime.

## Framework Orchestration

The verification follows a **Build-vs-Run Isolation** pattern:
1.  **Build Stage**: A standard SDK/Builder container (e.g., `mcr.microsoft.com/dotnet/sdk`) compiles the verification code into a portable binary.
2.  **Run Stage**: The compiled binary is executed inside our **Opensource Distroless Distroless** target image.
3.  **Assertion**: The workflow fails if any of the verification points (Runtime, SSL, or Timezone) return an error.

## Individual Runtime Pipelines

| Pipeline | Target Image | Verification App |
| :--- | :--- | :--- |
| [`test-dotnet.yml`](../../.github/workflows/test-dotnet.yml) | `dotnet:latest` | `E2E/dotnet/` |
| [`test-java.yml`](../../.github/workflows/test-java.yml) | `java:latest` | `E2E/java/` |
| [`test-nodejs.yml`](../../.github/workflows/test-nodejs.yml) | `nodejs:latest` | `E2E/nodejs/` |
| [`test-python3.yml`](../../.github/workflows/test-python3.yml) | `python3:latest` | `E2E/python3/` |
| [`test-perl.yml`](../../.github/workflows/test-perl.yml) | `perl:latest` | `E2E/perl/` |
| [`test-php.yml`](../../.github/workflows/test-php.yml) | `php:latest` | `E2E/php/` |
