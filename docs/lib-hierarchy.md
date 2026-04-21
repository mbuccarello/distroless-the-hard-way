# Library Hierarchy & Build Roadmap

This document maps the shared libraries across the Opensource Distroless hierarchy. It distinguishes between components built natively from source ("The Hard Way") and those currently extracted from Fedora for convenience.

## 1. Architectural Hierarchy Graph

![Library Hierarchy](images/lib-hierarchy.png)

---

## 2. Library Status Matrix

| Component | Status | Origin | Category |
|-----------|--------|--------|----------|
| `libc.so.6` | ✅ **Source** | GNU Source | Foundation |
| `libssl.so.3` | ✅ **Source** | OpenSSL Source | Foundation |
| `libz.so.1` | ✅ **Source** | Zlib Source | Foundation |
| `libstdc++.so.6` | ✅ **Source** | GCC Source | C++ Layer |
| `ca-certificates` | ⚠️ **Fedora Extract** | Fedora 40 | Security |
| `libicu*.so` | ⚠️ **Fedora Extract** | Fedora 40 | Dotnet Runtime |
| `libkrb5.so` | ⚠️ **Fedora Extract** | Fedora 40 | Networking |
| `libffi.so` | ⚠️ **Fedora Extract** | Fedora 40 | Python Runtime |
| `libxml2.so` | ⚠️ **Fedora Extract** | Fedora 40 | PHP Runtime |

---

## 3. Build From Source Roadmap

The following components are currently extracted from Fedora for convenience and are candidates for future "Hard Way" native compilation pipelines.

### Priority 1: Core System Utilities
- [ ] **ca-certificates**: Implement a native build from the Mozilla NSS trust store instead of extracting the Fedora bundle.
- [ ] **libicu**: Compile Unicode components from source to remove Dotnet's dependency on Fedora RPMs.

### Priority 2: Runtime Dependencies
- [ ] **libkrb5 (GSSAPI)**: Native compilation of Kerberos libraries.
- [ ] **libffi**: Native build for Python foreign function interface.
- [ ] **libxml2 / libedit**: Native builds for PHP and general CLI tools.

### Priority 3: Full Runtime Bootstrapping
- [ ] **Python 3 Interpreter**: Move from Fedora RPMs to a full native source compilation.
- [ ] **PHP 8.x Interpreter**: Move from Fedora RPMs to a full native source compilation.
