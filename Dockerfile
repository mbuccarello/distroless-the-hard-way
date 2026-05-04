# syntax=docker/dockerfile:1.4

# --- STAGE 0: BUILDER (The Source Compiler) ---
FROM fedora:40 as builder
# Install base tools
RUN dnf install -y @development-tools cmake curl git busybox perl python3
RUN if [ -f /usr/sbin/busybox ]; then ln -s /usr/sbin/busybox /usr/bin/busybox; fi

# Create standard Distroless RootFS
RUN mkdir -p /rootfs/etc/ssl/certs /rootfs/etc/pki/tls/certs /rootfs/usr/lib /rootfs/usr/share/zoneinfo /rootfs/tmp /rootfs/home/nonroot /rootfs/var/lib/apt/lists /rootfs/etc/ld.so.conf.d
RUN chmod 1777 /rootfs/tmp

# Dynamic Linker Configuration
RUN echo "/usr/lib" > /rootfs/etc/ld.so.conf && \
    echo "/lib" >> /rootfs/etc/ld.so.conf && \
    echo "include /etc/ld.so.conf.d/*.conf" >> /rootfs/etc/ld.so.conf

# Setup Users
RUN <<EOF
echo "root:x:0:0:root:/root:/sbin/nologin" > /rootfs/etc/passwd
echo "nonroot:x:65532:65532:nonroot:/home/nonroot:/sbin/nologin" >> /rootfs/etc/passwd
echo "root:x:0:" > /rootfs/etc/group
echo "nonroot:x:65532:" >> /rootfs/etc/group
EOF

# Netbase: Minimal Protocols and Services
RUN <<EOF
echo 'tcp 6/TCP' > /rootfs/etc/protocols
echo 'udp 17/UDP' >> /rootfs/etc/protocols
echo 'icmp 1/ICMP' >> /rootfs/etc/protocols
echo 'http 80/tcp' > /rootfs/etc/services
echo 'https 443/tcp' >> /rootfs/etc/services
EOF

# Universal FHS Unification
RUN ln -s usr/lib /rootfs/lib && ln -s usr/lib /rootfs/lib64

# Copy Core files from the builder environment
RUN cp -r /usr/share/zoneinfo /rootfs/usr/share/zoneinfo
RUN cp /etc/ssl/certs/ca-certificates.crt /rootfs/etc/ssl/certs/ca-certificates.crt
RUN cp /etc/os-release /rootfs/etc/os-release

# SSL Symlinks Compatibility
RUN ln -sf /etc/ssl/certs/ca-certificates.crt /rootfs/etc/ssl/cert.pem && \
    ln -sf /etc/ssl/certs/ca-certificates.crt /rootfs/etc/pki/tls/certs/ca-bundle.crt && \
    ln -sf /etc/ssl/certs/ca-certificates.crt /rootfs/etc/pki/tls/cert.pem

# --- LIBRARY BUILDER (Generic) ---
FROM builder as lib-builder
ARG LIB_NAME
ARG LIB_URL
ARG LIB_SHA
ARG LIB_CONFIG
ARG MAKE_EXTRA

WORKDIR /build

# Inject dependencies from contexts if they exist
RUN --mount=type=bind,target=/deps <<EOF
if [ -d /deps ]; then
    for dep in /deps/*; do
        if [ -d "$dep/artifacts/usr" ]; then
            cp -r "$dep/artifacts/usr" /usr
        fi
    done
fi

if [ -n "$LIB_URL" ]; then
    curl -L "$LIB_URL" -o source.tar.gz
    mkdir src && tar -xf source.tar.gz -C src --strip-components=1
    cd src
    ./configure --prefix=/usr $LIB_CONFIG
    make $MAKE_EXTRA
    make DESTDIR=/artifacts install
    
    # Automated License Harvesting
    mkdir -p /artifacts/usr/share/doc/$LIB_NAME
    find . -maxdepth 1 -iname "LICENSE*" -o -iname "COPYING*" -o -iname "NOTICE*" -o -iname "AUTHORS*" | xargs -I {} cp -r {} /artifacts/usr/share/doc/$LIB_NAME/
fi
EOF

# --- STAGE 1: STATIC (The Minimalist Root) ---
FROM scratch as static
COPY --from=builder /rootfs /
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
USER 65532:65532

# --- STAGE 1-DEBUG: STATIC-DEBUG ---
FROM static as static-debug
USER root
COPY --from=builder /usr/bin/busybox /usr/bin/busybox
RUN ["/usr/bin/busybox", "--install", "-s", "/usr/bin"]
USER 65532:65532

# --- STAGE 2: BASE (The Dynamic Linker) ---
FROM scratch as base
COPY --from=builder /rootfs /
COPY --from=builder /usr/lib/ld-linux-x86-64.so.2 /usr/lib/
COPY --from=builder /usr/lib/libc.so.6 /usr/lib/
COPY --from=builder /usr/lib/libm.so.6 /usr/lib/
COPY --from=builder /usr/lib/libdl.so.2 /usr/lib/
COPY --from=builder /usr/lib/libpthread.so.0 /usr/lib/
COPY --from=builder /usr/lib/librt.so.1 /usr/lib/
COPY --from=builder /usr/lib/libnss_dns.so.2 /usr/lib/
COPY --from=builder /usr/lib/libnss_files.so.2 /usr/lib/
COPY --from=builder /usr/lib/libresolv.so.2 /usr/lib/
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
USER 65532:65532

# --- STAGE 2-DEBUG: BASE-DEBUG ---
FROM base as base-debug
USER root
COPY --from=builder /usr/bin/busybox /usr/bin/busybox
RUN ["/usr/bin/busybox", "--install", "-s", "/usr/bin"]
USER 65532:65532

# --- STAGE 3: CC (The Foundation) ---
FROM base as cc
USER root
COPY --from=builder /usr/lib/libgcc_s.so.1 /usr/lib/
COPY --from=builder /usr/lib/libstdc++.so.6 /usr/lib/
USER 65532:65532
