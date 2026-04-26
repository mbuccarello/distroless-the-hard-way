> [!NOTE]
> **The Hard Way:** This is an educational tutorial pipeline. Every single step here performs compilation from raw source. We do not use Debian extraction.

# Distroless The Hard Way E2E Verification Framework

The Distroless-The-Hard-Way project implements a rigorous **End-to-End (E2E) Verification Framework** to ensure the technical integrity of every produced runtime image. Unlike simple smoke tests, our E2E suite validates critical system-level components that were natively compiled from source.

## Verification Objectives

Every E2E test application (Dotnet, Java, Node.js, etc.) is designed to prove two critical security and functionality points:

### 1. SSL/TLS Integrity (`openssl`)
- **Reasoning**: We do not trust host-provided OpenSSL binaries. Every runtime must prove it can perform a secure, verified HTTPS handshake using our Distroless The Hard Way-compiled OpenSSL layer.
- **Test**: The application performs an `HTTPS GET` request to `https://www.google.com`.
- **Proof**: Success proves that root CA certificates, cryptographic algorithms, and the OpenSSL shared library are correctly linked and functional.

### 2. Timezone Resolution (`tzdata`)
- **Reasoning**: Accurate time is critical for security logging and JWT validation.
- **Test**: The application resolves the `Europe/Rome` timezone and displays the current regional time.
- **Proof**: Success proves that our Distroless The Hard Way-compiled `tzdata` database is correctly mounted and readable by the high-level runtime.

## Framework Orchestration

The verification follows a **Build-vs-Run Isolation** pattern:
1.  **Build Stage**: A standard SDK/Builder container (e.g., `mcr.microsoft.com/dotnet/sdk`) compiles the verification code into a portable binary.
2.  **Run Stage**: The compiled binary is executed inside our **Distroless The Hard Way Distroless** target image.
3.  **Assertion**: The workflow fails if any of the verification points (Runtime, SSL, or Timezone) return an error.

## Individual Runtime Verification

Verification logic is integrated directly into the assembly pipelines to ensure atomic validation before image promotion.

| Assembly Pipeline | Target Image | Verification Logic |
| :--- | :--- | :--- |
| [`assemble-dotnet.yml`](../../.github/workflows/assemble-dotnet.yml) | `dotnet:latest` | `app/test-dotnet.cs` |
| [`assemble-java.yml`](../../.github/workflows/assemble-java.yml) | `java:latest` | `app/test.java` |
| [`assemble-nodejs.yml`](../../.github/workflows/assemble-nodejs.yml) | `nodejs:latest` | `app/test.js` |
| [`assemble-python3.yml`](../../.github/workflows/assemble-python3.yml) | `python3:latest` | `app/test.py` |
| [`assemble-perl.yml`](../../.github/workflows/assemble-perl.yml) | `perl:latest` | `app/test.pl` |
| [`assemble-php.yml`](../../.github/workflows/assemble-php.yml) | `php:latest` | `app/test.php` |
