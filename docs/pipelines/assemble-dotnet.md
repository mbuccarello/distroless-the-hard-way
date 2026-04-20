# Technical Specification: Distroless dotnet Assembly

This specification defines the construction of the dotnet Distroless image, providing a high-assurance runtime built upon the `cc` base layer.

---

## 1. Hierarchy Specification
- **Parent Image**: `ghcr.io/mbuccarello/cc:latest`
- **Artifact Source**: Verified upstream distribution for the dotnet runtime.

## 2. Implementation Logic
- **Assembly Strategy**: The runtime binaries are extracted into the zero-trust hierarchy using Stage 1 tools.
- **Hardening**: Unnecessary headers, documentation, and build-time shims are omitted to minimize the attack surface.

