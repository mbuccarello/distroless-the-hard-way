# syntax=docker/dockerfile:1.4

# --- STAGE 0: BUILDER (The Source Compiler) ---
FROM fedora:40 as builder
# Install base tools
RUN dnf install -y @development-tools cmake curl git busybox perl python3
RUN if [ -f /usr/sbin/busybox ]; then ln -s /usr/sbin/busybox /usr/bin/busybox; fi

# Create standard Distroless RootFS
RUN mkdir -p /rootfs/etc/ssl/certs /rootfs/etc/pki/tls/certs /rootfs/usr/lib /rootfs/usr/share/zoneinfo /rootfs/tmp /rootfs/home/nonroot /rootfs/var/lib/apt/lists /rootfs/etc/ld.so.conf.d

# Add essential users/groups
RUN echo "root:x:0:0:root:/root:/bin/sh" > /rootfs/etc/passwd && \
    echo "nonroot:x:65532:65532:nonroot:/home/nonroot:/bin/sh" >> /rootfs/etc/passwd && \
    echo "root:x:0:" > /rootfs/etc/group && \
    echo "nonroot:x:65532:" >> /rootfs/etc/group

# --- STAGE 1: STATIC (The Minimal Root) ---
FROM scratch as static
COPY --from=builder /rootfs /

# --- STAGE 2: BASE (The Glibc Foundation) ---
FROM static as base
# Copy Busybox for essential filesystem tasks
COPY --from=builder /usr/bin/busybox /usr/bin/busybox

# Copy Glibc and essential dynamic linker files from Fedora builder (lib64)
COPY --from=builder /usr/lib64/ld-linux-x86-64.so.2 /usr/lib/
COPY --from=builder /usr/lib64/libc.so.6 /usr/lib/
COPY --from=builder /usr/lib64/libm.so.6 /usr/lib/
COPY --from=builder /usr/lib64/libdl.so.2 /usr/lib/
COPY --from=builder /usr/lib64/librt.so.1 /usr/lib/
COPY --from=builder /usr/lib64/libpthread.so.0 /usr/lib/
COPY --from=builder /usr/lib64/libresolv.so.2 /usr/lib/
COPY --from=builder /usr/lib64/libutil.so.1 /usr/lib/
COPY --from=builder /usr/lib64/libcrypt.so.2 /usr/lib/

# Setup standard symlinks for maximum compatibility
RUN ["/usr/bin/busybox", "mkdir", "-p", "/lib64"]
RUN ["/usr/bin/busybox", "ln", "-s", "/usr/lib/ld-linux-x86-64.so.2", "/lib64/ld-linux-x86-64.so.2"]
RUN ["/usr/bin/busybox", "ln", "-s", "/usr/lib/libc.so.6", "/lib64/libc.so.6"]
RUN ["/usr/bin/busybox", "ln", "-s", "/usr/lib/libm.so.6", "/lib64/libm.so.6"]
RUN ["/usr/bin/busybox", "ln", "-s", "/usr/lib/libdl.so.2", "/lib64/libdl.so.2"]
RUN ["/usr/bin/busybox", "ln", "-s", "/usr/lib/librt.so.1", "/lib64/librt.so.1"]
RUN ["/usr/bin/busybox", "ln", "-s", "/usr/lib/libpthread.so.0", "/lib64/libpthread.so.0"]
RUN ["/usr/bin/busybox", "ln", "-s", "/usr/lib/libresolv.so.2", "/lib64/libresolv.so.2"]
RUN ["/usr/bin/busybox", "ln", "-s", "/usr/lib/libutil.so.1", "/lib64/libutil.so.1"]
RUN ["/usr/bin/busybox", "ln", "-s", "/usr/lib/libcrypt.so.2", "/lib64/libcrypt.so.2"]

USER 65532:65532
