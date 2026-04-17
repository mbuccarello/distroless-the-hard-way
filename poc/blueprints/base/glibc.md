# GNU C Library (glibc)

## Overview
The GNU C Library (`glibc`) is the core implementation of the standard C library used across almost all Linux environments. It defines the foundational system calls (like `malloc`, `printf`, `socket`) that bridge application logic with the underlying Linux kernel.

## Why compile from source?
Pre-compiled `libc6` packages from Debian or Alpine carry inherited supply chain risks. By downloading the direct `tar.gz` from the GNU FTP servers, we guarantee the cryptographically signed origin of our most critical execution layer. Compiling it securely ensures that we are the sole author of the foundation of the image.

## Build Configuration
Within `base.yaml`, we compile glibc directly from GNU source, configuring it securely for standard dynamic link loading across `/usr/lib`:
```bash
./configure --prefix=/usr --libdir=/usr/lib
make install DESTDIR=/sovereignforge_out
```
