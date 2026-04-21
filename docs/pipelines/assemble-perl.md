# Technical Specification: Distroless perl Assembly

This specification defines the construction of the perl Distroless image, providing a high-assurance runtime built upon the `cc` base layer.

---

## 1. Hierarchy Specification
- **Parent Image**: `ghcr.io/mbuccarello/cc:latest`
- **LTS Version**: Perl 5.38 (Fedora 40)
- **Provenance Strategy**: Type B (Official OS-Native RPM Extraction)

## 2. Implementation Logic
- **Assembly Strategy**: Official Fedora 40 Perl packages are downloaded via the `base-fedora` sandbox. Binaries are then extracted using `rpm2cpio`.
- **Zero-Compilation**: No Perl source code is compiled; the runtime is sourced directly from the official Fedora distribution.

