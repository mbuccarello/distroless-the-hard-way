FROM ghcr.io/mbuccarello/base-fedora:latest as builder
RUN dnf install -y gcc make autoconf pkg-config

# Inject Sovereign Foundations
COPY --from=ghcr.io/mbuccarello/cc:latest / /artifacts/
COPY --from=ghcr.io/mbuccarello/foundation-libffi:latest / /artifacts/
COPY --from=ghcr.io/mbuccarello/foundation-readline:latest / /artifacts/
COPY --from=ghcr.io/mbuccarello/foundation-ncurses:latest / /artifacts/
COPY --from=ghcr.io/mbuccarello/foundation-bzip2:latest / /artifacts/
COPY --from=ghcr.io/mbuccarello/foundation-liblzma:latest / /artifacts/
COPY --from=ghcr.io/mbuccarello/foundation-sqlite:latest / /artifacts/
COPY --from=ghcr.io/mbuccarello/foundation-libxcrypt:latest / /artifacts/

WORKDIR /build
RUN curl -L -o python.tar.gz https://www.python.org/ftp/python/3.12.5/Python-3.12.5.tgz
RUN tar -xzf python.tar.gz --strip-components=1

# Configure and Build
# Base libs (openssl) are in /artifacts/usr, runtime foundations in root of /artifacts
ENV PKG_CONFIG_PATH=/artifacts/lib/pkgconfig:/artifacts/lib64/pkgconfig:/artifacts/usr/lib64/pkgconfig:/artifacts/usr/lib/pkgconfig
ENV CPPFLAGS="-I/artifacts/include -I/artifacts/usr/include"
ENV LDFLAGS="-L/artifacts/lib -L/artifacts/lib64 -L/artifacts/usr/lib64 -L/artifacts/usr/lib -Wl,-rpath,/usr/local/lib:/artifacts/lib:/lib64:/lib"

# Explicitly guide GCC for sovereign discovery
ENV C_INCLUDE_PATH=/artifacts/include:/artifacts/usr/include
ENV LIBRARY_PATH=/artifacts/lib:/artifacts/lib64:/artifacts/usr/lib64:/artifacts/usr/lib

COPY scripts/assemble.sh /usr/local/bin/assemble
RUN chmod +x /usr/local/bin/assemble

RUN mkdir -p /rootfs && \
assemble python3 " ./configure --prefix=/usr/local \
--enable-optimizations \
--with-system-ffi \
--with-openssl=/artifacts/usr \
--with-zlib=/artifacts/usr \
--enable-shared && \
make -j$(nproc) && \
make install DESTDIR=/rootfs "

# Construct Final Distroless Image
FROM scratch
COPY --from=ghcr.io/mbuccarello/cc:latest / /
COPY --from=ghcr.io/mbuccarello/foundation-libffi:latest / /
COPY --from=ghcr.io/mbuccarello/foundation-readline:latest / /
COPY --from=ghcr.io/mbuccarello/foundation-ncurses:latest / /
COPY --from=ghcr.io/mbuccarello/foundation-bzip2:latest / /
COPY --from=ghcr.io/mbuccarello/foundation-liblzma:latest / /
COPY --from=ghcr.io/mbuccarello/foundation-sqlite:latest / /
COPY --from=ghcr.io/mbuccarello/foundation-libxcrypt:latest / /
COPY --from=builder /rootfs/usr/local /usr/local/

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LANG=C.UTF-8
ENTRYPOINT ["/usr/local/bin/python3"]
CMD ["--version"]
