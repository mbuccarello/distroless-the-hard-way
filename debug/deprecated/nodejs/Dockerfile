FROM fedora:40 as extractor
RUN mkdir -p /rootfs
COPY --from=ghcr.io/mbuccarello/cc:latest / /rootfs/
COPY payload/node.tar.gz /

RUN mkdir -p /rootfs/usr/local/lib/nodejs && tar -xzf /node.tar.gz -C /rootfs/usr/local/lib/nodejs

# Regenerate library cache
RUN ldconfig -r /rootfs
RUN ln -sf /usr/local/lib/nodejs/bin/node /rootfs/usr/bin/node
RUN ln -sf /usr/local/lib/nodejs/bin/npm /rootfs/usr/bin/npm

FROM scratch
COPY --from=extractor /rootfs /
ENV NODE_HOME=/usr/local/lib/nodejs
ENV PATH=\$NODE_HOME/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENTRYPOINT ["/usr/bin/node"]
