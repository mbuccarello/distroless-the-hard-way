
FROM builder AS zlib
ARG LIB_NAME=zlib
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src/$LIB_SUBDIR && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "bzip2" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS brotli
ARG LIB_NAME=brotli
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src/$LIB_SUBDIR && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "bzip2" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS openssl
ARG LIB_NAME=openssl
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
COPY --from=brotli /artifacts/usr /opt/distroless
COPY --from=zlib /artifacts/usr /opt/distroless
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src/$LIB_SUBDIR && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "bzip2" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS icu
ARG LIB_NAME=icu
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src/$LIB_SUBDIR && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "bzip2" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS ncurses
ARG LIB_NAME=ncurses
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src/$LIB_SUBDIR && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "bzip2" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS readline
ARG LIB_NAME=readline
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
COPY --from=ncurses /artifacts/usr /opt/distroless
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src/$LIB_SUBDIR && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "bzip2" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS libxml2
ARG LIB_NAME=libxml2
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
COPY --from=icu /artifacts/usr /opt/distroless
COPY --from=readline /artifacts/usr /opt/distroless
COPY --from=zlib /artifacts/usr /opt/distroless
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src/$LIB_SUBDIR && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "bzip2" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS sqlite
ARG LIB_NAME=sqlite
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
COPY --from=readline /artifacts/usr /opt/distroless
COPY --from=zlib /artifacts/usr /opt/distroless
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src/$LIB_SUBDIR && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "bzip2" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS oniguruma
ARG LIB_NAME=oniguruma
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src/$LIB_SUBDIR && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "bzip2" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS krb5
ARG LIB_NAME=krb5
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
COPY --from=openssl /artifacts/usr /opt/distroless
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src/$LIB_SUBDIR && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "bzip2" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS curl
ARG LIB_NAME=curl
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
COPY --from=brotli /artifacts/usr /opt/distroless
COPY --from=krb5 /artifacts/usr /opt/distroless
COPY --from=zlib /artifacts/usr /opt/distroless
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src/$LIB_SUBDIR && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "bzip2" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS libxcrypt
ARG LIB_NAME=libxcrypt
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src/$LIB_SUBDIR && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "bzip2" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS bzip2
ARG LIB_NAME=bzip2
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src/$LIB_SUBDIR && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "bzip2" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS pcre2
ARG LIB_NAME=pcre2
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
COPY --from=bzip2 /artifacts/usr /opt/distroless
COPY --from=readline /artifacts/usr /opt/distroless
COPY --from=zlib /artifacts/usr /opt/distroless
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src/$LIB_SUBDIR && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "bzip2" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS runtime-setup
USER root
RUN mkdir -p /runtime-root/usr /runtime-root/etc /runtime-root/var /opt/distroless
COPY --from=zlib /artifacts/usr /opt/distroless
COPY --from=brotli /artifacts/usr /opt/distroless
COPY --from=openssl /artifacts/usr /opt/distroless
COPY --from=icu /artifacts/usr /opt/distroless
COPY --from=ncurses /artifacts/usr /opt/distroless
COPY --from=readline /artifacts/usr /opt/distroless
COPY --from=libxml2 /artifacts/usr /opt/distroless
COPY --from=sqlite /artifacts/usr /opt/distroless
COPY --from=oniguruma /artifacts/usr /opt/distroless
COPY --from=krb5 /artifacts/usr /opt/distroless
COPY --from=curl /artifacts/usr /opt/distroless
COPY --from=libxcrypt /artifacts/usr /opt/distroless
COPY --from=bzip2 /artifacts/usr /opt/distroless
COPY --from=pcre2 /artifacts/usr /opt/distroless
RUN set -ex && curl -L "https://www.php.net/distributions/php-8.3.13.tar.xz" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr --enable-fpm --with-openssl --with-zlib --with-curl --enable-mbstring --with-mysqli --with-pdo-mysql --with-external-pcre; elif [ -f ./Configure ]; then ./Configure --enable-fpm --with-openssl --with-zlib --with-curl --enable-mbstring --with-mysqli --with-pdo-mysql --with-external-pcre; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr --enable-fpm --with-openssl --with-zlib --with-curl --enable-mbstring --with-mysqli --with-pdo-mysql --with-external-pcre .; fi && \
    make -j$(nproc) && make DESTDIR=/runtime-root install

FROM cc AS runtime
USER root
ARG RUNTIME_NAME
ARG RUNTIME_VER
LABEL distroless.stack="${RUNTIME_NAME}"
COPY --from=runtime-setup /runtime-root/usr/ /usr/
COPY --from=runtime-setup /runtime-root/etc/ /etc/
COPY --from=runtime-setup /runtime-root/var/ /var/
USER 65532:65532

FROM runtime AS runtime-debug
USER root
COPY --from=builder /usr/bin/busybox /usr/bin/busybox
RUN ["/usr/bin/busybox", "--install", "-s", "/usr/bin"]
USER 65532:65532
