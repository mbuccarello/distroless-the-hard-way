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
COPY --from=libxcrypt /artifacts/usr /usr
COPY --from=libffi /artifacts/usr /usr
COPY --from=expat /artifacts/usr /usr
COPY --from=bzip2 /artifacts/usr /usr
COPY --from=xz /artifacts/usr /usr
COPY --from=ncurses /artifacts/usr /usr
COPY --from=readline /artifacts/usr /usr
COPY --from=sqlite /artifacts/usr /usr
LABEL distroless.layer="cc"
USER 65532:65532
