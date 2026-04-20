# Pipeline Specification: Stage 1 Static Bootstrap

The Stage 1 Bootstrap utility is the primary tool used for image assembly. It provides the minimal filesystem manipulation capabilities needed to construct a rootfs from absolute zero.

---

## 1. Physical Specification

To achieve absolute zero-trust, the bootstrap utility must run in a `FROM scratch` vacuum without relying on external system libraries.

- **Implementation**: Strictly Static BusyBox.
- **Linkage**: 100% Statically linked against GNU C Library (Glibc).
- **Environment**: Compiled on a Fedora host to ensure Glibc-native compatibility.

## 2. Build Rationale

The use of a custom-built, static bootstrap utility prevents environmental contamination from the host build system. It ensures that every command (mkdir, sh, tar) in the assembly phase is verified, signed, and fully understood.

---

## 3. Artifact Distribution

- **Target**: `ghcr.io/mbuccarello/bootstrap:latest`
- **Format**: Single atomic binary provided in a scratch container.

