# Gap Analysis: Distroless The Hard Way vs. Google Distroless and Wolfi

This document evaluates the architectural alignment of this project with industry standards (Google Distroless) and modern atomic distributions (Wolfi), tracking our progress toward 100% source sovereignty.

## 1. Architectural Progress Matrix

| Feature | Project Status | Reference (Google/Wolfi) | Gap / Status |
| :--- | :--- | :--- | :--- |
| **Layer Hierarchy** | `static -> base -> cc` | Google Distroless | **Aligned**: 100% parity with Google's 3-tier core hierarchy. |
| **Root Trust** | Sovereign (Mozilla NSS) | Google/Wolfi | **Resolved**: Certificates are built from source, eliminating the Fedora CA dependency. |
| **System Config** | Sovereign (Hard Way) | Wolfi | **Resolved**: /etc/services, /etc/passwd, and /etc/protocols are manually constructed. |
| **Package Management** | OCI-Native Metadata | Wolfi (apk) | **Divergent Strategy**: We leverage OCI registry metadata for traceability instead of a runtime package database. |
| **Runtime Compilation** | Hybrid (Fedora Extract) | Wolfi | **Active Gap**: PHP, Python, and Perl still rely on Fedora RPM extraction. |

---

## 2. Updated Evolution Roadmap

### Phase 1: OCI-Native Traceability (Completed)
Instead of a local database, we utilize the OCI registry as a distributed package store.
- **Achievement**: Versioning, signatures (Cosign), and provenance (SLSA) are attached to OCI artifacts.
- **Result**: Final images remain zero-footprint (no /var/lib/rpm).

### Phase 2: OpenMP and C++ Parity (Completed)
Achieving full parity with Google's cc image.
- **Achievement**: Integrated native compilation of libgomp and libstdc++.
- **Result**: Support for advanced multi-threaded runtimes (Java, .NET) is now native.

### Phase 3: Sovereign Runtime Bootstrapping (In Progress)
Eliminating the "Fedora Bridge" for high-level language runtimes.
- **Target**: PHP 8.3 and Python 3.12.
- **Action**: Develop native compilation pipelines that build the interpreters directly from upstream source within the Foundation layer.
- **Goal**: Reach 100% source-to-binary sovereignty for the entire stack.

### Phase 4: Declarative Assembly (Long Term)
Transitioning from imperative shell scripts to a declarative assembly engine.
- **Action**: Researching a minimal, YAML-based assembly tool (similar to apko) that leverages our OCI-packaged foundations.
- **Goal**: Bit-for-bit reproducibility across any build environment.

---

## 3. Case Study: The "Fedora Noise" Problem
Recent attempts to extract Perl and PHP via `dnf download --resolve` highlighted the gap:
- **Wolfi approach**: They define exactly which files go into a package. If a dependency is missing, the build fails.
- **Our hybrid approach**: DNF often pulls hundreds of unnecessary packages, creating "noise" that complicates security auditing and debugging.
- **The Lesson**: Minimalism isn't just about size; it's about **predictability**. The move to Phase 3 (Sovereign Compilation) is the only way to eliminate this noise permanently.
