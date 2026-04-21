# Technical Specification: Distroless dotnet Assembly

This specification defines the construction of the dotnet Distroless image, providing a high-assurance runtime built upon the `cc` base layer.

---

## 1. Hierarchy Specification
- **Parent Image**: `ghcr.io/mbuccarello/cc:latest`
- **LTS Version**: .NET 8.0 Runtime
- **Provenance Strategy**: Type A (Official Native Tarball)

## 2. Implementation Logic
- **Assembly Strategy**: The runtime binaries are downloaded from the official Microsoft distribution mirrors and verified against the official SHA512 manifest.
- **Zero-Compilation**: Only pre-compiled official Microsoft binaries are extracted.

