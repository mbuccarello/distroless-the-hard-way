# Technical Specification: Distroless php Assembly

This specification defines the construction of the php Distroless image, providing a high-assurance runtime built upon the `cc` base layer.

---

## 1. Hierarchy Specification
- **Parent Image**: `ghcr.io/mbuccarello/cc:latest`
- **LTS Version**: PHP 8.3.11 (Latest Stable)
- **Provenance Strategy**: Type B (Sovereign Source Compilation)

## 2. Implementation Logic
- **Assembly Strategy**: PHP is compiled from source within the `base-fedora` sandbox, linking against sovereign foundations (`libffi`, `libxml2`, `oniguruma`, `sqlite`, `libxcrypt`).
- **RPATH Hardening**: Binaries are built with `-Wl,-rpath,/usr/local/lib` to ensure sovereign library discovery.
- **Verification**: Functional assertions via `app/test.php`.

