# Technical Specification: Distroless java Assembly

This specification defines the construction of the java Distroless image, providing a high-assurance runtime built upon the `cc` base layer.

---

## 1. Hierarchy Specification
- **Parent Image**: `ghcr.io/mbuccarello/cc:latest`
- **LTS Version**: Java 17 (Adoptium Temurin)
- **Provenance Strategy**: Type A (Official Native Tarball)

## 2. Implementation Logic
- **Assembly Strategy**: The runtime binaries are downloaded directly from the official Adoptium mirrors and verified against the project's SHA256 manifest.
- **Zero-Compilation**: No Java source code is compiled during this stage; only verified binaries are extracted.

