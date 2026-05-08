# syntax=docker/dockerfile:1.4
FROM base AS cc
USER root
RUN mkdir -p /usr/lib64
COPY --from=builder /usr/lib64/libgcc_s.so.1 /usr/lib64/
COPY --from=builder /usr/lib64/libstdc++.so.6 /usr/lib64/
RUN ln -sf /usr/lib64/libgcc_s.so.1 /usr/lib/libgcc_s.so.1 && \
    ln -sf /usr/lib64/libstdc++.so.6 /usr/lib/libstdc++.so.6
COPY --from=zlib /artifacts/usr /usr
COPY --from=brotli /artifacts/usr /usr
COPY --from=bzip2 /artifacts/usr /usr
COPY --from=libpng /artifacts/usr /usr
COPY --from=freetype2 /artifacts/usr /usr
COPY --from=libjpeg-turbo /artifacts/usr /usr
COPY --from=lcms2 /artifacts/usr /usr
COPY --from=libx11 /artifacts/usr /usr
COPY --from=libxext /artifacts/usr /usr
COPY --from=libxrender /artifacts/usr /usr
COPY --from=libxtst /artifacts/usr /usr
COPY --from=alsa-lib /artifacts/usr /usr
COPY --from=openssl /artifacts/usr /usr
COPY --from=libxcrypt /artifacts/usr /usr
LABEL distroless.layer="cc"
USER 65532:65532
