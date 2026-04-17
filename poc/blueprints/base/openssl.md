# OpenSSL

## Overview
OpenSSL is a robust, commercial-grade toolkit for general-purpose cryptography and secure communication protocols (TLS/SSL). 

## Why compile from source?
Cryptography is the most sensitive layer of any application. Pre-compiled SSH/TLS libraries represent an enormous supply chain vulnerability if structurally compromised (e.g., the `xz-utils` attack). By mathematically confirming the source from `openssl.org` and compiling it in an empty sandbox, we establish definitive trust that our network traffic is encrypted utilizing exact verifiable algorithms.

## Build Configuration
For Opensource-Distroless, OpenSSL is deliberately compiled with the `no-shared` flag, ensuring static reliability and minimal attack surface parsing:
```bash
./config --prefix=/usr --openssldir=/etc/ssl no-shared
make install_sw DESTDIR=/sovereignforge_out
```
