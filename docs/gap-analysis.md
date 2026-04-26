[<- Back to Main README](../README.md)

# Gap Analysis: Distroless The Hard Way vs. Industry Standards

This document evaluates the architectural alignment of this project with industry standards (Google Distroless and Wolfi), tracking our progress toward 100% source sovereignty.

## 1. Architectural Progress Matrix

| Feature | Project Status | Reference | Status |
| :--- | :--- | :--- | :--- |
| **Layer Hierarchy** | 4-Tier Sovereign | Google Distroless | **Exceeded**: Our 4-layer model (L1, L1.5, L2, L3) provides better modularity than the standard 3-tier model. |
| **Root Trust** | Sovereign (Mozilla NSS) | Google/Wolfi | **Resolved**: 100% source-built trust store. |
| **System Config** | Sovereign (Hard Way) | Wolfi | **Resolved**: Manual construction of /etc/services, /etc/passwd. |
| **Package Management** | OCI-Native Metadata | Wolfi (apk) | **Divergent Strategy**: We use the OCI Registry as a distributed package manager, eliminating runtime databases. |
| **Runtime Sovereignty** | 100% Source Build | Wolfi | **Resolved**: PHP, Python, and Perl are natively compiled, removing all "Fedora Noise". |

---

## 2. Strategic Evolution

### Phase 3: Sovereign Runtime Bootstrapping (Completed)
- **Achievement**: Native compilation pipelines for PHP 8.3, Python 3.12, and Perl 5.38.
- **Result**: 100% source-to-binary sovereignty for the interpreted stack, linked against sovereign foundations (libxml2, libffi, ncurses).

### Phase 4: Enterprise LTS Stabilization (Current)
- **Objective**: Hardening the pipeline for Enterprise LTS runtimes (Java 21, Node.js 22, .NET 8).
- **Hardening**: These "Binary Type A" runtimes are now injected into images containing our sovereign foundations, ensuring security parity with source-built runtimes.
- **Diagnostics**: Implementation of the universal `debug/` folder ecosystem for localized troubleshooting.

---

## 3. Case Study: The "Fedora Noise" Problem (Resolved)

The project has transitioned from a hybrid extraction model to a **Pure Assembly Model**.

- **The Problem**: Using `dnf download --resolve` for runtimes like Perl pulled in over 100 unverified OS dependencies, violating the "Hard Way" principle.
- **The Solution**: By building interpreters from source and linking them against Layer 1.5 (Runtime Foundations), we have eliminated 100% of the Fedora-specific metadata and binary noise.
- **The Result**: Final runtime images are 40-60% smaller than their hybrid predecessors and possess a cryptographically verified bill-of-materials (SBOM).
