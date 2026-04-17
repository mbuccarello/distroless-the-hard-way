# tzdata

## Overview
`tzdata` (Time Zone Database) represents the standard cryptographic library for global IANA timezones and daylight saving time configurations, used extensively by Unix-like applications to process chronological logic.

## Why compile from source?
Extracting pre-compiled timezone packages often carries hidden payload configurations from the distribution. Compiling `tzdata` directly ensures an untampered interpretation of time across servers, crucial for generating authentic TLS certificates and cryptographic signatures natively.

## Build Configuration
The internet timezone repository is extracted and mapped directly into the `/usr/share/zoneinfo` block without shell scripts:
```bash
make install DESTDIR=/sovereignforge_out ZONEDIR=/usr/share/zoneinfo
```
