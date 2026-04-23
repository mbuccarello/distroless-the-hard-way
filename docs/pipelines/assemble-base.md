# Technical Specification: Stage 3 Base OS Assembly

The Base OS Assembler is responsible for merging the atomic Stage 2 payloads into a functional, minimal OCI root filesystem.

---

## 🏗️ Assembly Process: The Canonical Chain

The `base` image is no longer built from scratch. It follows a strictly additive model:

1.  **Inheritance**: `FROM ghcr.io/[owner]/static:latest`.
2.  **Payload Injection**: The dynamic foundation tarballs (`glibc`, `openssl`, `zlib`) are extracted into the rootfs.
3.  **Library Discovery**: `ldconfig` is executed to generate the binary runtime cache (`/etc/ld.so.cache`).
4.  **Metadata Update**: `/etc/os-release` is updated to reflect the `Base` variant.

## 📦 Key Components
- **glibc**: GNU C Library (Source-built).
- **openssl**: Crypto engine (Source-built).
- **zlib**: Compression (Source-built).
- **Everything from `static`**: Certs, tzdata, users, netbase.
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
