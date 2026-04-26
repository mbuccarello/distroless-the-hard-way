FROM fedora:40 as builder
RUN mkdir -p /rootfs/etc/ssl/certs /rootfs/etc/pki/tls/certs /rootfs/usr/bin /rootfs/tmp /rootfs/home/nonroot /rootfs/root
RUN chmod 1777 /rootfs/tmp

# Copy Sovereign Foundations
COPY --from=ghcr.io/mbuccarello/artifacts-cacerts:latest /cacerts-layer.tar.gz /
COPY --from=ghcr.io/mbuccarello/artifacts-tzdata:latest /tzdata-layer.tar.gz /

# Extract foundations
RUN tar -xzf /cacerts-layer.tar.gz -C /rootfs
RUN tar -xzf /tzdata-layer.tar.gz -C /rootfs

# --- THE HARD WAY: Sovereign Config Files ---

# Identity: root and canonical nonroot (65532)
RUN echo 'root:x:0:0:root:/root:/bin/sh' > /rootfs/etc/passwd && \
echo 'nonroot:x:65532:65532:nonroot:/home/nonroot:/sbin/nologin' >> /rootfs/etc/passwd && \
echo 'root:x:0:' > /rootfs/etc/group && \
echo 'nonroot:x:65532:' >> /rootfs/etc/group

# Netbase: Minimal Services and Protocols
RUN echo 'tcp 6/TCP' > /rootfs/etc/protocols && \
echo 'udp 17/UDP' >> /rootfs/etc/protocols && \
echo 'icmp 1/ICMP' >> /rootfs/etc/protocols && \
echo 'http 80/tcp' > /rootfs/etc/services && \
echo 'https 443/tcp' >> /rootfs/etc/services && \
echo 'ssh 22/tcp' >> /rootfs/etc/services

# Metadata: Canonical os-release
RUN echo 'NAME="Opensource Distroless"' > /rootfs/etc/os-release && \
echo 'ID=opensource-distroless' >> /rootfs/etc/os-release && \
echo 'PRETTY_NAME="Opensource Distroless (Static)"' >> /rootfs/etc/os-release && \
echo 'VARIANT="Static"' >> /rootfs/etc/os-release

# SSL Symlinks Compatibility
RUN ln -sf /etc/ssl/certs/ca-certificates.crt /rootfs/etc/ssl/cert.pem && \
ln -sf /etc/ssl/certs/ca-certificates.crt /rootfs/etc/pki/tls/certs/ca-bundle.crt && \
ln -sf /etc/ssl/certs/ca-certificates.crt /rootfs/etc/pki/tls/cert.pem

FROM scratch
COPY --from=builder /rootfs /
USER 65532:65532
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
