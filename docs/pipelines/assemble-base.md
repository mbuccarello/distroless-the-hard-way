# Technical Specification: Stage 3 Base OS Assembly

The Base OS Assembler is responsible for merging the atomic Stage 2 payloads into a functional, minimal OCI root filesystem.

---

## 1. Assembly Logic

The process follows a strict zero-trust sequence using the Stage 1 Static Bootstrap utility.

### Prerequisite Checklist
1. **Verification**: intermediate artifacts (`glibc`, `openssl`, `zlib`, `tzdata`) must be verified for Cosign signatures and SLSA provenance.
2. **Environment**: The assembly occurs within a `FROM scratch` context to ensure the absence of host-OS artifacts.

### Operational Sequence
- **Filesystem Creation**: The Stage 1 Bootstrap utility initializes the `/rootfs` hierarchy.
- **Payload Extraction**: Each foundation tarball is extracted independently into the rootfs.
- **System Configuration**: Essential files (`/etc/passwd`, `/etc/group`) are generated with minimal, unprivileged defaults.
- **Final Packaging**: The resulting rootfs is promoted to the final `base:latest` image.

---

## 2. Technical Audit & Gating

The final base image undergoes several security gates before publication:
- **Vulnerability Scan (Trivy)**: Comprehensive CVE scanning of the assembled libraries.
- **Capability Analysis (Malcontent)**: Inspection of binaries to verify that no unexpected capabilities or malicious patterns were introduced during assembly.
- **Integrity Attestation**: SLSA Level 3 provenance for the final OS product.

---

## 3. Product Distribution

- **Target**: `ghcr.io/mbuccarello/base:latest`
- **Specification**: A minimal OCI image containing only the core libraries and timezone data, intended for Go, Rust, and static binary runtimes.
