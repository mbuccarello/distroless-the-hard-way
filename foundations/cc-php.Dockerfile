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
COPY --from=openssl /artifacts/usr /usr
COPY --from=icu /artifacts/usr /usr
COPY --from=ncurses /artifacts/usr /usr
COPY --from=readline /artifacts/usr /usr
COPY --from=libxml2 /artifacts/usr /usr
COPY --from=sqlite /artifacts/usr /usr
COPY --from=oniguruma /artifacts/usr /usr
COPY --from=krb5 /artifacts/usr /usr
COPY --from=curl /artifacts/usr /usr
COPY --from=libxcrypt /artifacts/usr /usr
COPY --from=bzip2 /artifacts/usr /usr
COPY --from=pcre2 /artifacts/usr /usr
LABEL distroless.layer="cc"
USER 65532:65532
