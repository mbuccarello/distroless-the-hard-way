
FROM builder AS zlib-builder
ARG LIB_NAME=zlib
ARG LIB_URL
ARG LIB_CONFIG
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; fi && \
    if [ "$LIB_NAME" = "bzip2" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS openssl-builder
ARG LIB_NAME=openssl
ARG LIB_URL
ARG LIB_CONFIG
COPY --from=zlib /artifacts/usr /opt/distroless
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; fi && \
    if [ "$LIB_NAME" = "bzip2" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS libxcrypt-builder
ARG LIB_NAME=libxcrypt
ARG LIB_URL
ARG LIB_CONFIG
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; fi && \
    if [ "$LIB_NAME" = "bzip2" ]; then make -j$(nproc) PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j$(nproc) && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS runtime-setup
USER root
RUN mkdir -p /runtime-root/usr
ARG RUNTIME_URL
RUN set -ex && mkdir -p /tmp/py && curl -L "$RUNTIME_URL" -o /tmp/runtime.tar.gz && \
    tar -xf /tmp/runtime.tar.gz -C /tmp/py && PY_DIR=$(find /tmp/py -name bin -type d | head -n 1 | xargs dirname) && cp -rv $PY_DIR/* /runtime-root/usr/

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
