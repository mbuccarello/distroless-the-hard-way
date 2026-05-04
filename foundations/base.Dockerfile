# syntax=docker/dockerfile:1.4

# --- STAGE 2: BASE (The Glibc Foundation) ---
# Inherits from the static foundation
FROM ghcr.io/mbuccarello/static:latest as base

# Copy Busybox for essential filesystem tasks during assembly
COPY --from=builder /usr/bin/busybox /usr/bin/busybox

# Setup essential FHS structure using JSON form
RUN ["/usr/bin/busybox", "mkdir", "-p", "/usr/lib", "/usr/lib64", "/usr/bin", "/bin", "/etc/ld.so.conf.d"]
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

# Configure the dynamic linker
RUN echo "/usr/lib" > /etc/ld.so.conf && \
    echo "/usr/lib64" >> /etc/ld.so.conf && \
    echo "include /etc/ld.so.conf.d/*.conf" >> /etc/ld.so.conf

LABEL distroless.layer="base"
USER 65532:65532
