
FROM builder AS zlib
ARG LIB_NAME=zlib
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src/$LIB_SUBDIR && \
    mkdir -p /opt/distroless && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless || true && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all || true && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "icu" ]; then make -j1 && make DESTDIR=/artifacts install; elif [ "$LIB_NAME" = "bzip2" ]; then make -j2 PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j2 && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS brotli
ARG LIB_NAME=brotli
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src/$LIB_SUBDIR && \
    mkdir -p /opt/distroless && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless || true && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all || true && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "icu" ]; then make -j1 && make DESTDIR=/artifacts install; elif [ "$LIB_NAME" = "bzip2" ]; then make -j2 PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j2 && make DESTDIR=/artifacts install; fi; \
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
    mkdir -p /opt/distroless && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless || true && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all || true && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "icu" ]; then make -j1 && make DESTDIR=/artifacts install; elif [ "$LIB_NAME" = "bzip2" ]; then make -j2 PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j2 && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS icu
ARG LIB_NAME=icu
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    dnf install -y libicu-devel && \
    mkdir -p /artifacts/usr/lib64 /artifacts/usr/include && \
    cp -rv /usr/lib64/libicu* /artifacts/usr/lib64/ && \
    cp -rv /usr/include/unicode /artifacts/usr/include/ && \
    echo "ICU installed via dnf"; \
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
    mkdir -p /opt/distroless && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless || true && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all || true && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "icu" ]; then make -j1 && make DESTDIR=/artifacts install; elif [ "$LIB_NAME" = "bzip2" ]; then make -j2 PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j2 && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS libxcrypt
ARG LIB_NAME=libxcrypt
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src/$LIB_SUBDIR && \
    mkdir -p /opt/distroless && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless || true && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all || true && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "icu" ]; then make -j1 && make DESTDIR=/artifacts install; elif [ "$LIB_NAME" = "bzip2" ]; then make -j2 PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j2 && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS runtime-setup
USER root
RUN mkdir -p /runtime-root/usr /runtime-root/etc /runtime-root/var /opt/distroless
COPY --from=zlib /artifacts/usr /opt/distroless
COPY --from=brotli /artifacts/usr /opt/distroless
COPY --from=openssl /artifacts/usr /opt/distroless
COPY --from=icu /artifacts/usr /opt/distroless
COPY --from=krb5 /artifacts/usr /opt/distroless
COPY --from=libxcrypt /artifacts/usr /opt/distroless
ARG RUNTIME_NAME=dotnet
ARG RUNTIME_URL
RUN set -ex && mkdir -p /tmp/extract && \
    if [ "$RUNTIME_URL" = "DNF" ]; then \
      dnf clean all && dnf install -y --setopt=install_weak_deps=False $RUNTIME_NAME $RUNTIME_NAME-fpm $RUNTIME_NAME-mysqlnd $RUNTIME_NAME-opcache $RUNTIME_NAME-xml $RUNTIME_NAME-mbstring $RUNTIME_NAME-gd $RUNTIME_NAME-curl || dnf install -y $RUNTIME_NAME && \
      mkdir -p /runtime-root/usr/bin /runtime-root/usr/sbin /runtime-root/usr/lib64 /runtime-root/usr/lib /runtime-root/usr/share /runtime-root/etc && \
      cp -rv /usr/bin/${RUNTIME_NAME}* /runtime-root/usr/bin/ || true && \
      cp -rv /usr/sbin/${RUNTIME_NAME}* /runtime-root/usr/sbin/ || true && \
      cp -rv /usr/lib64/${RUNTIME_NAME}* /runtime-root/usr/lib64/ || true && \
      cp -rv /usr/lib/${RUNTIME_NAME}* /runtime-root/usr/lib/ || true && \
      cp -rv /usr/share/${RUNTIME_NAME}* /runtime-root/usr/share/ || true && \
      cp -rv /usr/lib64/lib${RUNTIME_NAME}* /runtime-root/usr/lib64/ || true && \
      cp -rv /etc/${RUNTIME_NAME}* /runtime-root/etc/ || true && \
      echo "Runtime installed via dnf"; \
    else \
      curl -L "$RUNTIME_URL" -o /tmp/runtime.tar.gz && \
      mkdir -p /tmp/extract && tar -xf /tmp/runtime.tar.gz -C /tmp/extract && \
      if [ "$RUNTIME_NAME" = "dotnet" ]; then \
        mkdir -p /runtime-root/usr/share/dotnet && cp -rv /tmp/extract/* /runtime-root/usr/share/dotnet/ && \
        mkdir -p /runtime-root/usr/bin && ln -sf /usr/share/dotnet/dotnet /runtime-root/usr/bin/dotnet; \
      else \
        BIN_DIR=$(find /tmp/extract -name bin -type d | head -n 1) && \
        if [ -n "$BIN_DIR" ]; then \
          SRC_DIR=$(dirname "$BIN_DIR"); \
          cp -rv "$SRC_DIR"/* /runtime-root/usr/; \
        else \
          cp -rv /tmp/extract/* /runtime-root/usr/; \
        fi; \
      fi; \
    fi

FROM cc AS runtime
USER root
ARG RUNTIME_NAME
ARG RUNTIME_VER
LABEL distroless.stack="${RUNTIME_NAME}"
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH="${PATH}:/usr/share/dotnet"
COPY --from=runtime-setup /runtime-root/usr/ /usr/
USER 65532:65532

FROM runtime AS runtime-debug
USER root
COPY --from=builder /usr/bin/busybox /usr/bin/busybox
RUN ["/usr/bin/busybox", "--install", "-s", "/usr/bin"]
USER 65532:65532
