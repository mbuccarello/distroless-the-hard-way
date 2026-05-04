# syntax=docker/dockerfile:1.4

# --- STAGE 1: STATIC (The Minimal Root) ---
FROM scratch as static

# Create the rootfs skeleton
# This is typically provided via a tarball from the builder, 
# or by copying the minimal files needed for a functional root.

# Expects 'builder' context to be provided via Bake
COPY --from=builder /rootfs /

# Set standard metadata
LABEL distroless.layer="static"
LABEL org.opencontainers.image.source="https://github.com/mbuccarello/distroless-the-hard-way"

# Root environment
USER 65532:65532
WORKDIR /home/nonroot
