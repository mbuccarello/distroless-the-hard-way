FROM ghcr.io/mbuccarello/base-fedora:latest as builder
RUN dnf install -y gcc make autoconf bison re2c pkgconfig \
    libxml2-devel sqlite-devel openssl-devel zlib-devel \
    libffi-devel oniguruma-devel file diffutils

WORKDIR /build
# Target PHP 8.3.11 (Latest Stable)
RUN curl -L -o php.tar.xz https://www.php.net/distributions/php-8.3.11.tar.xz
RUN tar -xJf php.tar.xz --strip-components=1

# Pull sovereign foundations
COPY --from=ghcr.io/mbuccarello/foundation-libffi:latest / /artifacts/
COPY --from=ghcr.io/mbuccarello/foundation-libxml2:latest / /artifacts/
COPY --from=ghcr.io/mbuccarello/foundation-oniguruma:latest / /artifacts/
COPY --from=ghcr.io/mbuccarello/foundation-sqlite:latest / /artifacts/
COPY --from=ghcr.io/mbuccarello/foundation-libxcrypt:latest / /artifacts/

ENV PKG_CONFIG_PATH=/artifacts/lib/pkgconfig:/artifacts/lib64/pkgconfig
ENV CPPFLAGS="-I/artifacts/include"
ENV LDFLAGS="-L/artifacts/lib -L/artifacts/lib64 -Wl,-rpath,/usr/local/lib:/artifacts/lib:/lib64:/lib"

# Note: assemble.sh logic is manually expanded here for local debugging
RUN ./configure --prefix=/usr/local \
    --with-config-file-path=/etc/php \
    --enable-fpm \
    --enable-mbstring \
    --with-openssl \
    --with-zlib \
    --with-libxml \
    --with-ffi \
    --with-sqlite3 \
    --with-iconv \
    --disable-cgi
RUN make -j$(nproc)
RUN mkdir -p /rootfs && \
    make install INSTALL_ROOT=/rootfs && \
    ls -R /rootfs/usr/local/bin/php && \
    ls -R /rootfs/usr/local

FROM scratch
COPY --from=ghcr.io/mbuccarello/base:latest / /
COPY --from=ghcr.io/mbuccarello/foundation-libffi:latest /lib64/. /usr/local/lib/
COPY --from=ghcr.io/mbuccarello/foundation-libffi:latest /include/. /usr/local/include/
COPY --from=ghcr.io/mbuccarello/foundation-libxml2:latest /lib/. /usr/local/lib/
COPY --from=ghcr.io/mbuccarello/foundation-libxml2:latest /include/. /usr/local/include/
COPY --from=ghcr.io/mbuccarello/foundation-oniguruma:latest /lib/. /usr/local/lib/
COPY --from=ghcr.io/mbuccarello/foundation-oniguruma:latest /include/. /usr/local/include/
COPY --from=ghcr.io/mbuccarello/foundation-sqlite:latest /lib/. /usr/local/lib/
COPY --from=ghcr.io/mbuccarello/foundation-sqlite:latest /include/. /usr/local/include/
COPY --from=ghcr.io/mbuccarello/foundation-libxcrypt:latest /lib/. /usr/local/lib/
COPY --from=ghcr.io/mbuccarello/foundation-libxcrypt:latest /include/. /usr/local/include/
COPY --from=builder /rootfs/usr/local /usr/local/

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LANG=C.UTF-8
ENTRYPOINT ["/usr/local/bin/php"]
CMD ["-v"]
