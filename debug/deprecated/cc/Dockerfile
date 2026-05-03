FROM fedora:40 as extractor
RUN mkdir -p /rootfs
COPY --from=ghcr.io/mbuccarello/base:latest / /rootfs/
COPY --from=ghcr.io/mbuccarello/artifacts-gcc:latest /gcc-layer.tar.gz /
RUN tar -xzf /gcc-layer.tar.gz -C /rootfs
RUN ldconfig -r /rootfs

FROM scratch
COPY --from=extractor /rootfs /
