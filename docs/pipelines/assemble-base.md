# Technical Specification: Stage 3 Base OS Assembly

The Base OS Assembler is responsible for merging the atomic Stage 2 payloads into a functional, minimal OCI root filesystem.

---

## 1. Assembly Logic

The process follows a strict zero-trust sequence using the Stage 1 Static Bootstrap utility.

### Prerequisite Checklist
1. **Verification**: Intermediate artifacts (`glibc`, `openssl`, `zlib`, `tzdata`) must be verified for Cosign signatures (Manual Binary v2.4.1) and SLSA v2 provenance.
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
- **Capability Analysis (Malcontent)**: Inspection of binaries to verify that no legacy or insecure capabilities are present.
- **Integrity Attestation**: SLSA Level 3 provenance via `actions/attest-build-provenance@v2`.

---

## 3. Product Distribution

- **Target**: `ghcr.io/${{ github.repository_owner }}/base:latest`
- **Specification**: A minimal OCI image containing only the core libraries and timezone data, intended for Go, Rust, and static binary runtimes.
