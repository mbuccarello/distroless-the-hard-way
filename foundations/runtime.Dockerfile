
FROM builder AS zlib-builder
ARG LIB_NAME=zlib
ARG LIB_URL
ARG LIB_CONFIG
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && \
    mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && \
    cd src && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; \
    elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; \
    fi && \
    if [ "$LIB_NAME" = "bzip2" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; \
    else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS openssl-builder
ARG LIB_NAME=openssl
ARG LIB_URL
ARG LIB_CONFIG
COPY --from=zlib /artifacts/usr /opt/distroless
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && \
    mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && \
    cd src && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; \
    elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; \
    fi && \
    if [ "$LIB_NAME" = "bzip2" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; \
    else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS libxcrypt-builder
ARG LIB_NAME=libxcrypt
ARG LIB_URL
ARG LIB_CONFIG
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && \
    mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && \
    cd src && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; \
    elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; \
    fi && \
    if [ "$LIB_NAME" = "bzip2" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; \
    else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS libffi-builder
ARG LIB_NAME=libffi
ARG LIB_URL
ARG LIB_CONFIG
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && \
    mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && \
    cd src && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; \
    elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; \
    fi && \
    if [ "$LIB_NAME" = "bzip2" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; \
    else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS expat-builder
ARG LIB_NAME=expat
ARG LIB_URL
ARG LIB_CONFIG
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && \
    mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && \
    cd src && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; \
    elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; \
    fi && \
    if [ "$LIB_NAME" = "bzip2" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; \
    else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS bzip2-builder
ARG LIB_NAME=bzip2
ARG LIB_URL
ARG LIB_CONFIG
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && \
    mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && \
    cd src && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; \
    elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; \
    fi && \
    if [ "$LIB_NAME" = "bzip2" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; \
    else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS xz-builder
ARG LIB_NAME=xz
ARG LIB_URL
ARG LIB_CONFIG
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && \
    mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && \
    cd src && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; \
    elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; \
    fi && \
    if [ "$LIB_NAME" = "bzip2" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; \
    else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS ncurses-builder
ARG LIB_NAME=ncurses
ARG LIB_URL
ARG LIB_CONFIG
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && \
    mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && \
    cd src && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; \
    elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; \
    fi && \
    if [ "$LIB_NAME" = "bzip2" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; \
    else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS readline-builder
ARG LIB_NAME=readline
ARG LIB_URL
ARG LIB_CONFIG
COPY --from=ncurses /artifacts/usr /opt/distroless
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && \
    mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && \
    cd src && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; \
    elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; \
    fi && \
    if [ "$LIB_NAME" = "bzip2" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; \
    else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS sqlite-builder
ARG LIB_NAME=sqlite
ARG LIB_URL
ARG LIB_CONFIG
COPY --from=readline /artifacts/usr /opt/distroless
COPY --from=zlib /artifacts/usr /opt/distroless
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && \
    mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && \
    cd src && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; \
    elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; \
    fi && \
    if [ "$LIB_NAME" = "bzip2" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; \
    else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS runtime-setup
USER root
RUN mkdir -p /runtime-root/usr
COPY --from=zlib /artifacts/usr /runtime-root/usr
COPY --from=openssl /artifacts/usr /runtime-root/usr
COPY --from=libxcrypt /artifacts/usr /runtime-root/usr
COPY --from=libffi /artifacts/usr /runtime-root/usr
COPY --from=expat /artifacts/usr /runtime-root/usr
COPY --from=bzip2 /artifacts/usr /runtime-root/usr
COPY --from=xz /artifacts/usr /runtime-root/usr
COPY --from=ncurses /artifacts/usr /runtime-root/usr
COPY --from=readline /artifacts/usr /runtime-root/usr
COPY --from=sqlite /artifacts/usr /runtime-root/usr
ARG RUNTIME_URL
RUN set -ex && mkdir -p /tmp/py && curl -L "$RUNTIME_URL" -o /tmp/runtime.tar.gz && \
    tar -xf /tmp/runtime.tar.gz -C /tmp/py && \
    PY_DIR=$(find /tmp/py -name bin -type d | head -n 1 | xargs dirname) && \
    cp -rv $PY_DIR/* /runtime-root/usr/

FROM base AS cc
USER root
COPY --from=builder /usr/lib64/libgcc_s.so.1 /usr/lib/
COPY --from=builder /usr/lib64/libstdc++.so.6 /usr/lib/
COPY --from=zlib /artifacts/usr /usr
COPY --from=openssl /artifacts/usr /usr
COPY --from=libxcrypt /artifacts/usr /usr
COPY --from=libffi /artifacts/usr /usr
COPY --from=expat /artifacts/usr /usr
COPY --from=bzip2 /artifacts/usr /usr
COPY --from=xz /artifacts/usr /usr
COPY --from=ncurses /artifacts/usr /usr
COPY --from=readline /artifacts/usr /usr
COPY --from=sqlite /artifacts/usr /usr

FROM cc AS runtime
USER root
ARG RUNTIME_NAME
ARG RUNTIME_VER
LABEL distroless.stack="${RUNTIME_NAME}"
COPY --from=runtime-setup /runtime-root/usr/ /usr/
USER 65532:65532

FROM runtime AS runtime-debug
USER root
COPY --from=builder /usr/bin/busybox /usr/bin/busybox
RUN ["/usr/bin/busybox", "--install", "-s", "/usr/bin"]
USER 65532:65532
