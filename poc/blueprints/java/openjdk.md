# OpenJDK (Adoptium)

## Overview
The Eclipse Temurin (Adoptium) OpenJDK is the foremost industry-standard open-source binary distribution of the Java SE platform. It acts as the high-level execution engine for modern enterprise applications.

## Why use Pre-Compiled Binaries?
While Distroless-The-Hard-Way demands that **System OS Libraries** (like `glibc` and `openssl`) be iteratively compiled from pure C-code to permanently sever the dependency on external OS maintainers (Debian/Alpine), **Application Libraries** represent a different threat footprint.

The OpenJDK binary requires zero host-OS capabilities; it functions exclusively as a sandbox running on top of the System OS Libraries. By simply verifying the Adoptium cryptographic signature and mathematically binding the raw `.tar.gz` payload strictly over our sovereign `sovereign-distroless/cc` runtime, we achieve the identical zero-trust integrity threshold without enduring a massive 45-minute JVM C-compilation hurdle.

## Build Configuration
The OpenJDK archive is simply unpacked organically and structurally routed to standard PATH alignments:
```bash
cp -r src_java/* /sovereignforge_out/usr/lib/jvm/
```
