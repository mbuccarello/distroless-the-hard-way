# syntax=docker/dockerfile:1.4
FROM base AS cc
USER root
COPY --from=builder /usr/lib64/libgcc_s.so.1 /usr/lib/
COPY --from=builder /usr/lib64/libstdc++.so.6 /usr/lib/
COPY --from=zlib /artifacts/usr /usr
COPY --from=openssl /artifacts/usr /usr
COPY --from=icu /artifacts/usr /usr
COPY --from=brotli /artifacts/usr /usr
COPY --from=c-ares /artifacts/usr /usr
COPY --from=nghttp2 /artifacts/usr /usr
COPY --from=libxcrypt /artifacts/usr /usr
LABEL distroless.layer="cc"
USER 65532:65532
