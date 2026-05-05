
# --- STAGE 0: BUILDER (The Source Compiler) ---
FROM fedora:40 as builder

# Install base tools
RUN dnf install -y @development-tools cmake curl git busybox perl python3 xz tar bison flex gettext texinfo

# Ensure Busybox is in path
RUN if [ -f /usr/sbin/busybox ]; then ln -s /usr/sbin/busybox /usr/bin/busybox; fi

# Create standard Distroless RootFS structure (to be used by base image)
RUN mkdir -p /rootfs/etc/ssl/certs /rootfs/etc/pki/tls/certs /rootfs/usr/lib /rootfs/usr/share/zoneinfo /rootfs/tmp /rootfs/home/nonroot /rootfs/var/lib/apt/lists /rootfs/etc/ld.so.conf.d

# Add essential users/groups
RUN echo "root:x:0:0:root:/root:/bin/sh" > /rootfs/etc/passwd && \
    echo "nonroot:x:65532:65532:nonroot:/home/nonroot:/bin/sh" >> /rootfs/etc/passwd && \
    echo "root:x:0:" > /rootfs/etc/group && \
    echo "nonroot:x:65532:" >> /rootfs/etc/group
