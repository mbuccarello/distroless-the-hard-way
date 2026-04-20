# zlib

## Overview
`zlib` is the industry-standard software library used for data compression. It is frequently utilized natively by dynamic ELF binaries and network packets.

## Why compile from source?
Almost every high-level language runtime (including Java and Node) relies natively on `zlib` to uncompress libraries and payloads. By compiling the `zlib` API from standard C-code, Distroless-The-Hard-Way ensures that file I/O operations and compression streams are strictly handled by our sovereign binaries without inherited upstream OS vulnerabilities.

## Build Configuration
The Distroless-The-Hard-Way base blueprint targets the `/usr` prefix for dynamic linking, securely installing `libz.so` into the artifact:
```bash
./configure --prefix=/usr
make install DESTDIR=/sovereignforge_out
```
