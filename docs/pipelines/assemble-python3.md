# Technical Specification: Distroless python3 Assembly

This specification defines the construction of the python3 Distroless image, providing a high-assurance runtime built upon the `cc` base layer.

---

## 1. Hierarchy Specification
- **Parent Image**: `ghcr.io/mbuccarello/cc:latest`
- **LTS Version**: Python 3.12 (Fedora 40)
- **Provenance Strategy**: Type B (Official OS-Native RPM Extraction)

## 2. Implementation Logic
- **Assembly Strategy**: Official Fedora 40 packages are downloaded from the project mirrors using the `base-fedora` sandbox. Binaries are then extracted using `rpm2cpio`.
- **Zero-Compilation**: No Python source code is compiled; the system uses the official, security-patched binaries provided by the Fedora Project maintainers.

