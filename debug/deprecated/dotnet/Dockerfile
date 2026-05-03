FROM fedora:40 as extractor
RUN dnf install -y cpio
RUN mkdir -p /rootfs
COPY --from=ghcr.io/mbuccarello/cc:latest / /rootfs/
COPY --from=ghcr.io/mbuccarello/foundation-libxcrypt:latest / /rootfs/
COPY --from=ghcr.io/mbuccarello/foundation-liblzma:latest / /rootfs/
COPY payload/dotnet.tar.gz /
COPY payload/rpm /payload

RUN mkdir -p /rootfs/usr/share/dotnet && tar -xzf /dotnet.tar.gz -C /rootfs/usr/share/dotnet

# Extract RPM dependencies safely
RUN cd /payload && \
for f in *.rpm; do rpm2cpio \$f | cpio -idmv; done && \
cp -a usr/* /rootfs/usr/

# Regenerate library cache to include new dependencies
RUN ldconfig -r /rootfs
RUN ln -sf /usr/share/dotnet/dotnet /rootfs/usr/bin/dotnet

FROM scratch
COPY --from=extractor /rootfs /
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH=\$PATH:/usr/share/dotnet
ENTRYPOINT ["dotnet"]
