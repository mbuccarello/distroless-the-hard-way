# syntax=docker/dockerfile:1.4

# --- STAGE 1: STATIC (The Minimal Root) ---
FROM scratch as static
# Expects 'builder' context to be provided via Bake
COPY --from=builder /rootfs /

# --- STAGE 2: BASE (The Glibc Foundation) ---
FROM static as base
# Copy Busybox for essential filesystem tasks
COPY --from=builder /usr/bin/busybox /usr/bin/busybox

# Setup essential glibc libraries (ABI-stable bridges)
# Fedora 40 uses /usr/lib64, but we need to ensure they are found in /lib64 for legacy binaries
RUN mkdir -p /usr/lib64 /lib64 && \
    ["/usr/bin/busybox", "ln", "-s", "/usr/lib", "/lib"] && \
    ["/usr/bin/busybox", "ln", "-s", "/usr/lib64", "/lib64"]

# Inject essential glibc shared objects from the builder
COPY --from=builder /usr/lib64/libc.so.6 /usr/lib64/
COPY --from=builder /usr/lib64/libm.so.6 /usr/lib64/
COPY --from=builder /usr/lib64/librt.so.1 /usr/lib64/
COPY --from=builder /usr/lib64/libpthread.so.0 /usr/lib64/
COPY --from=builder /usr/lib64/libdl.so.2 /usr/lib64/
COPY --from=builder /usr/lib64/libresolv.so.2 /usr/lib64/
COPY --from=builder /usr/lib64/ld-linux-x86-64.so.2 /usr/lib64/

# Configure the dynamic linker
RUN echo "/usr/lib" > /etc/ld.so.conf && \
    echo "/usr/lib64" >> /etc/ld.so.conf && \
    echo "include /etc/ld.so.conf.d/*.conf" >> /etc/ld.so.conf
