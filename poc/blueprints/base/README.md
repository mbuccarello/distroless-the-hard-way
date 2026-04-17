# Base Blueprint

The `base` image is the absolute root of the Opensource-Distroless architecture. In a traditional container, this layer would be `FROM debian` or `FROM alpine`. In Opensource-Distroless, we achieve absolute sovereignty by replacing the host OS with a strictly compiled tier of foundational libraries.

## Foundational Components Compiled from Source

This blueprint compiles the lowest-level C-libraries required by almost all modern languages and runtimes.

*   [**`glibc` (The GNU C Library)**](glibc.md): The absolute core API between the Linux Kernel and the user-space applications.
*   [**`openssl` (Cryptography)**](openssl.md): Industry-standard TLS and cryptography suite. 
*   [**`zlib` (Compression)**](zlib.md): The definitive data compression library natively required by ELF dynamically linked binaries.
*   [**`tzdata` (Timezones)**](tzdata.md): The IANA timezone database for internet-time execution.
