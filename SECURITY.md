# Security Policy

## Supported Versions

We actively provide security updates for the following versions of Opensource-Distroless:

| Version | Supported          |
| ------- | ------------------ |
| V2.x    | :white_check_mark: |
| V1.x    | :x:                |

## Reporting a Vulnerability

We take the security of the Opensource-Distroless build engine seriously. If you believe you have found a security vulnerability, please report it to us responsibly.

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via one of the following methods:
1. **GitHub Security Advisory**: Use the "Report a vulnerability" button on the repository's "Security" tab.
2. **Email**: [Directly contact the maintainers - placeholder]

### Our Response Process
- We will acknowledge receipt of your report within 48 hours.
- We will provide an estimated timeframe for a fix.
- We will notify you once the vulnerability has been patched.

## Zero-Trust Mandate
Opensource-Distroless is designed to prevent supply chain attacks. If you discover a bypass in our SAST/SCA gating or a way to inject untrusted binaries into the sovereign base image without detection, we consider this a **High Severity** finding.
