# Technical Specification: Distroless perl Assembly

This specification defines the construction of the perl Distroless image, providing a high-assurance runtime built upon the `cc` base layer.

---

## 1. Hierarchy Specification
- **Parent Image**: `ghcr.io/mbuccarello/cc:latest`
- **LTS Version**: Perl 5.38.2
- **Provenance Strategy**: Type B (Sovereign Source Compilation)

## 2. Implementation Logic
- **Assembly Strategy**: Perl is compiled from source within the `base-fedora` sandbox, using a relocatable configuration (`-Dprefix=/usr/local`).
- **Sovereign Linking**: Linked against `libxcrypt` and `libxml2` foundations.
- **Verification**: Functional assertions via `app/test.pl`.

