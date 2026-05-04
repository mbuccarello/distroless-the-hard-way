# syntax=docker/dockerfile:1.4

# --- STAGE 3: CC (ABI-Stabilized Base) ---
# Inherits from the base foundation
FROM ghcr.io/mbuccarello/base:latest as cc
USER root

# Inject common C-runtime libraries from the builder
COPY --from=builder /usr/lib64/libgcc_s.so.1 /usr/lib/
COPY --from=builder /usr/lib64/libstdc++.so.6 /usr/lib/

# Inject common compiled libraries (the "Melange" outputs)
# These are provided as contexts during the CC build
COPY --from=zlib /artifacts/usr /usr
COPY --from=openssl /artifacts/usr /usr
COPY --from=libxcrypt /artifacts/usr /usr

LABEL distroless.layer="cc"
USER 65532:65532
