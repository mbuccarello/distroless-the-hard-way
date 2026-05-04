# syntax=docker/dockerfile:1.4

# --- STAGE 1: STATIC (The Minimal Root) ---
FROM scratch as static
# Expects 'builder' context to be provided via Bake
COPY --from=builder /rootfs /

# --- STAGE 2: BASE (The Glibc Foundation) ---
FROM static as base
# Copy Busybox for essential filesystem tasks
COPY --from=builder /usr/bin/busybox /usr/bin/busybox

# Setup essential FHS structure using JSON form (since no shell exists yet)
RUN ["/usr/bin/busybox", "mkdir", "-p", "/usr/lib64", "/lib64", "/usr/lib", "/lib", "/bin", "/etc/ld.so.conf.d"]
RUN ["/usr/bin/busybox", "ln", "-s", "/usr/lib", "/lib"]
RUN ["/usr/bin/busybox", "ln", "-s", "/usr/lib64", "/lib64"]
RUN ["/usr/bin/busybox", "ln", "-s", "/usr/bin/busybox", "/bin/sh"]

# Inject essential glibc shared objects from the builder
COPY --from=builder /usr/lib64/libc.so.6 /usr/lib64/
COPY --from=builder /usr/lib64/libm.so.6 /usr/lib64/
COPY --from=builder /usr/lib64/librt.so.1 /usr/lib64/
COPY --from=builder /usr/lib64/libpthread.so.0 /usr/lib64/
COPY --from=builder /usr/lib64/libdl.so.2 /usr/lib64/
COPY --from=builder /usr/lib64/libresolv.so.2 /usr/lib64/
COPY --from=builder /usr/lib64/ld-linux-x86-64.so.2 /usr/lib64/

# Configure the dynamic linker (now we have /bin/sh via busybox)
RUN echo "/usr/lib" > /etc/ld.so.conf && \
    echo "/usr/lib64" >> /etc/ld.so.conf && \
    echo "include /etc/ld.so.conf.d/*.conf" >> /etc/ld.so.conf
