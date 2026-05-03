[<- Back to Main README](../README.md)

# Library Hierarchy & Sovereignty Status

This document maps the shared libraries across the Unified Distroless hierarchy. Every component in this stack is built natively from upstream source code to ensure absolute data transparency and ABI stability.

## 1. Architectural Hierarchy Graph

![Library Hierarchy](images/lib-hierarchy.png)

## 2. Sovereignty Status: 100% Decoupled

The project has achieved **Total Decoupling** across all foundations and runtimes. We no longer extract binaries, libraries, or metadata from Fedora, Alpine, or Debian. Every `.so` file is a product of our independent build engine.

## 3. Unified Library Matrix

| Component | Hierarchy | Sourcing | Rationale |
| :--- | :--- | :--- | :--- |
| `libc.so.6` | `base` | Source (GNU) | Core C runtime foundation. |
| `libssl.so.3` | `cc` | Source (OpenSSL) | Unified crypto provider. |
| `libicu*.so` | `cc` | Source (Unicode) | Globalization for .NET/Node.js. |
| `libkrb5.so` | `cc` | Source (MIT) | GSSAPI support for .NET. |
| `libffi.so` | `cc` | Source (Libffi) | Dynamic calling for Python. |
| `libxml2.so` | `cc` | Source (GNOME) | XML support for PHP/Web stacks. |
| `libncurses.so`| `cc` | Source (GNU) | Terminal handling (Debug images). |
| `libxcrypt.so` | `base` | Source (Besser82) | Modern password hashing. |

## 4. FHS & ABI Standards

*   **Unification Path**: All shared objects are consolidated in `/usr/lib`.
*   **RPATH Strategy**: Every sovereign binary is built with `-Wl,-rpath,/usr/lib` to ensure it only discovers our verified foundations.
*   **Dynamic Linker Cache**: The engine automatically executes `ldconfig` during assembly to ensure the cache matches the bit-perfect filesystem layout.

## 5. Compliance & Metadata

Every library in the hierarchy includes its corresponding `LICENSE` and `AUTHORS` files under `/usr/share/doc/<package>/`, harvested automatically by the Distroless Engine during the build process.
