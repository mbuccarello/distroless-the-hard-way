# Use our new static layer as the foundation
FROM ghcr.io/mbuccarello/static:latest as static
# Use Fedora 40 as a powerful extractor to prepare the rootfs
FROM fedora:40 as extractor
COPY --from=static / /rootfs/

# Copy dynamic foundational layers
COPY --from=ghcr.io/mbuccarello/artifacts-glibc:latest /glibc-layer.tar.gz /
COPY --from=ghcr.io/mbuccarello/artifacts-zlib:latest /zlib-layer.tar.gz /
COPY --from=ghcr.io/mbuccarello/artifacts-openssl:latest /openssl-layer.tar.gz /

# Extract dynamic foundations into rootfs
RUN tar -xzf /glibc-layer.tar.gz -C /rootfs
RUN tar -xzf /zlib-layer.tar.gz -C /rootfs
RUN tar -xzf /openssl-layer.tar.gz -C /rootfs

# --- NATIVE LIBRARY DISCOVERY (LDCONFIG) ---
RUN echo '/usr/local/lib' > /rootfs/etc/ld.so.conf && \
echo '/usr/lib64' >> /rootfs/etc/ld.so.conf && \
echo '/usr/lib' >> /rootfs/etc/ld.so.conf && \
echo '/lib64' >> /rootfs/etc/ld.so.conf && \
echo '/lib' >> /rootfs/etc/ld.so.conf

# Generate the binary cache using the host's ldconfig in the rootfs context
RUN ldconfig -r /rootfs

# Update Metadata for Base variant
RUN sed -i 's/Static/Base (glibc)/' /rootfs/etc/os-release

# Final Assembly: Strictly Verified Opensource Distroless Base
FROM scratch
COPY --from=extractor /rootfs /
USER 0:0
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV TZ=UTC
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
