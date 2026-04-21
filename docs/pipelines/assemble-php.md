# Technical Specification: Distroless php Assembly

This specification defines the construction of the php Distroless image, providing a high-assurance runtime built upon the `cc` base layer.

---

## 1. Hierarchy Specification
- **Parent Image**: `ghcr.io/mbuccarello/cc:latest`
- **LTS Version**: PHP 8.3 (Fedora 40)
- **Provenance Strategy**: Type B (Official OS-Native RPM Extraction)

## 2. Implementation Logic
- **Assembly Strategy**: Official Fedora 40 PHP packages (CLI, Common, XML) are downloaded via the `base-fedora` sandbox. Binaries are then extracted using `rpm2cpio`.
- **Zero-Compilation**: No PHP source code is compiled; the runtime is sourced directly from the official Fedora distribution.

