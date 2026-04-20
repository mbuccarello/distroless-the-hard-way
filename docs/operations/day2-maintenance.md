# Specification: Operational Maintenance (Day 2)

This document defines the operational procedures for sustaining the integrity and security of the Distroless The Hard Way infrastructure.

---

## 1. Build Environment Constraints

### GNU C Library (Glibc)
Foundational components must be compiled on a Glibc-native Fedora host. Compiling GNU libraries on musl-based hosts (e.g., Alpine) is prohibited due to system header conflicts.

### Timezone Data (tzdata)
Version 2024b and later requires a dual-source strategy, merging `tzcode` and `tzdata` tarballs to produce the finalized database.

## 2. ABI Stability and Patching
When applying security patches to foundational libraries (glibc, openssl), maintainers must verify that ABI compatibility is preserved to prevent breakage of downstream language interpreters.

