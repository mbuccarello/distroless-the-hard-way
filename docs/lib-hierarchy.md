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
| `libgcc_s.so.1` | ✅ **Source** | GCC Source | C++ Layer |
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

---

## 4. Fedora Dependency Mapping (dnf download)

Each flavor is constructed by taking the **CC Image** as a base and injecting the specific runtime plus its OS-level dependencies. These dependencies are currently extracted from official Fedora RPMs to ensure binary compatibility with the source-built `glibc`.

All libraries are unified into `/usr/lib` (and symlinked from `/lib`) to ensure maximum compatibility without requiring `LD_LIBRARY_PATH` or complex `ld.so.conf` configurations, following the **Undistro** principle of simplicity and high-assurance.

### 🐍 Python 3 Flavor
- `python3`, `python3-libs`: Core interpreter and standard library.
- `libffi`, `expat`, `readline`: Runtime support.
- `sqlite-libs`, `gdbm-libs`, `libdb`: Storage backends.
- `libnsl2`, `libtirpc`, `libxcrypt`: Legacy and encryption support.
- `openssl-libs`, `zlib`: Networking and compression (transitional).

### ✨ .NET 8 Flavor
- `libicu`: Unicode and globalization support (required for runtime start).
- `krb5-libs`: Kerberos and GSSAPI support for advanced networking.

### 🐘 PHP 8.3 Flavor
- `php-cli`, `php-common`, `php-xml`: Core interpreter and XML module.
- `libxml2`, `pcre2`: XML parsing and regex engine.
- `libedit`, `ncurses-libs`: CLI interaction.
- `xz-libs`, `bzip2-libs`: Compression support.

### 🐪 Perl 5.38 Flavor
- `perl-interpreter`, `perl-libs`: Core interpreter.
- `perl-HTTP-Tiny`, `perl-IO-Socket-SSL`: SSL/Networking support.
- `libxcrypt`, `gdbm-libs`: Utility libraries.
