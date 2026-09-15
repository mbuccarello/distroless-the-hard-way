# Security Policy

This document covers vulnerability *reporting*. For the project's security architecture (signing, SBOM, hardening, scanner limitations), see [`docs/SECURITY.md`](docs/SECURITY.md).

## Supported Versions

Distroless-The-Hard-Way does not publish versioned releases; images are published as `:latest` (and `:debug`) tags, rebuilt continuously from the `main` branch. Security fixes are applied to `main` and take effect on the next fleet rebuild — there is no older version line receiving separate patches.

## Reporting a Vulnerability

We take the security of the Distroless-The-Hard-Way build engine seriously. If you believe you have found a security vulnerability, please report it to us responsibly.

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via:
- **GitHub Security Advisory**: Use the "Report a vulnerability" button on the repository's "Security" tab.

### Our Response Process
- We will acknowledge receipt of your report within 48 hours.
- We will provide an estimated timeframe for a fix.
- We will notify you once the vulnerability has been patched.

## Zero-Trust Mandate
Distroless-The-Hard-Way is designed to prevent supply chain attacks. If you discover a way to inject untrusted binaries into the sovereign base image without detection, or a gap in our signing/provenance chain, we consider this a **High Severity** finding.
