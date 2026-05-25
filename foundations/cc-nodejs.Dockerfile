# syntax=docker/dockerfile:1.4
FROM builder AS cc-setup
RUN mkdir -p /cc-root/usr/lib64 /cc-root/usr/lib /cc-root/etc && \
    ln -sf usr/lib /cc-root/lib && \
    ln -sf usr/lib64 /cc-root/lib64
COPY --from=builder /usr/lib64/libgcc_s.so.1 /cc-root/usr/lib64/
COPY --from=builder /usr/lib64/libstdc++.so.6 /cc-root/usr/lib64/
RUN ln -sf /usr/lib64/libgcc_s.so.1 /cc-root/usr/lib/libgcc_s.so.1 && \
    ln -sf /usr/lib64/libstdc++.so.6 /cc-root/usr/lib/libstdc++.so.6
COPY --from=zlib /artifacts/usr /cc-root/usr
COPY --from=brotli /artifacts/usr /cc-root/usr
COPY --from=openssl /artifacts/usr /cc-root/usr
COPY --from=icu /artifacts/usr /cc-root/usr
COPY --from=c-ares /artifacts/usr /cc-root/usr
COPY --from=nghttp2 /artifacts/usr /cc-root/usr
COPY --from=libxcrypt /artifacts/usr /cc-root/usr
RUN ldconfig -r /cc-root

FROM base AS cc
USER root
COPY --from=cc-setup /cc-root/usr/ /usr/
COPY --from=cc-setup /cc-root/etc/ /etc/
LABEL distroless.layer="cc"
USER 65532:65532
