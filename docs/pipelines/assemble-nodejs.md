# Technical Specification: Distroless nodejs Assembly

This specification defines the construction of the nodejs Distroless image, providing a high-assurance runtime built upon the `cc` base layer.

---

## 1. Hierarchy Specification
- **Parent Image**: `ghcr.io/mbuccarello/cc:latest`
- **LTS Version**: Node.js 20
- **Provenance Strategy**: Type A (Official Native Tarball)

## 2. Implementation Logic
- **Assembly Strategy**: The runtime binaries are downloaded directly from `nodejs.org` and verified against the official SHASUMS256 manifest.
- **Zero-Compilation**: Only pre-compiled official binaries are extracted into the hierarchy.

