> [!NOTE]
> **The Hard Way:** This is an educational tutorial pipeline. Every single step here performs compilation from raw source. We do not use Debian extraction.

# Opensource Distroless E2E Verification: Python 3

This pipeline verifies the technical integrity of the [`python3:latest`](assemble-python3.md) image.

## Verification Logic
It executes a Python 3 script to assert:
- **Runtime Integrity**: Successful execution of the indygreg Standalone CPython engine.
- **SSL/TLS Handshake**: Secure request to `google.com` via Opensource Distroless-compiled OpenSSL.
- **Timezone Accuracy**: Resolution of `Europe/Rome` via Opensource Distroless-compiled `tzdata`.

For a deep-dive into our verification strategy, see the [Opensource Distroless E2E Verification Framework](e2e-verification.md).
