# Pipeline Step: Assemble Static

The `static` image is the foundational OCI root of the Opensource Distroless project. It is designed for purely static binaries (e.g., Go, Rust) and contains zero shared libraries.

## 🛠️ Implementation Details

### Base Environment
- **Source**: `scratch`
- **Identity**: `nonroot` (UID 65532)

### Components
1.  **Sovereign Trust Store**: Extracted from Mozilla NSS. Located at `/etc/ssl/certs/ca-certificates.crt`.
2.  **Timezone Data**: Compiled from IANA source. Located at `/usr/share/zoneinfo`.
3.  **Netbase (Sovereign)**: 
    - `/etc/services`: Minimal map (http, https, ssh).
    - `/etc/protocols`: Minimal map (tcp, udp, icmp).
4.  **Identity Files**:
    - `/etc/passwd`: Defines `root` and `nonroot`.
    - `/etc/group`: Defines `root` and `nonroot`.

## 🏗️ Assembly Process

The assembly is performed within a Fedora-based builder but the resulting image is a clean `FROM scratch` export:

1.  **Extract Payloads**: Foundation tarballs (`cacerts`, `tzdata`) are expanded into a temporary rootfs.
2.  **Manual Configuration**: Files like `/etc/os-release` and `/etc/services` are generated via `cat` to ensure absolute minimalism.
3.  **FHS Setup**: Creation of standard directories (`/tmp`, `/home/nonroot`, `/etc/ssl/certs`).
4.  **Permissions**: `/tmp` is set to `1777` for standard compatibility.

## 🛡️ Security Verification
- **User Enforcement**: The image defaults to `USER 65532:65532`.
- **Environment**: `SSL_CERT_FILE` is hardcoded to point to the sovereign bundle.
