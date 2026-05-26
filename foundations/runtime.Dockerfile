
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
    export CFLAGS="$CFLAGS -g0 -O1 -fstack-protector-strong -D_FORTIFY_SOURCE=2" && \
    export CXXFLAGS="$CXXFLAGS -g0 -O1 -fstack-protector-strong -D_FORTIFY_SOURCE=2" && \
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless || true && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all || true && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "icu" ]; then make -j1 && make DESTDIR=/artifacts install; elif [ "$LIB_NAME" = "bzip2" ]; then make -j2 PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j2 && make DESTDIR=/artifacts install; fi && \
    mkdir -p /artifacts/usr/share/doc/$LIB_NAME && \
    find . -maxdepth 2 -type f \( -iname "license*" -o -iname "copying*" -o -iname "mit-license*" \) -exec cp -v {} /artifacts/usr/share/doc/$LIB_NAME/ \; -quit; \
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
    export CFLAGS="$CFLAGS -g0 -O1 -fstack-protector-strong -D_FORTIFY_SOURCE=2" && \
    export CXXFLAGS="$CXXFLAGS -g0 -O1 -fstack-protector-strong -D_FORTIFY_SOURCE=2" && \
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless || true && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all || true && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "icu" ]; then make -j1 && make DESTDIR=/artifacts install; elif [ "$LIB_NAME" = "bzip2" ]; then make -j2 PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j2 && make DESTDIR=/artifacts install; fi && \
    mkdir -p /artifacts/usr/share/doc/$LIB_NAME && \
    find . -maxdepth 2 -type f \( -iname "license*" -o -iname "copying*" -o -iname "mit-license*" \) -exec cp -v {} /artifacts/usr/share/doc/$LIB_NAME/ \; -quit; \
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
    export CFLAGS="$CFLAGS -g0 -O1 -fstack-protector-strong -D_FORTIFY_SOURCE=2" && \
    export CXXFLAGS="$CXXFLAGS -g0 -O1 -fstack-protector-strong -D_FORTIFY_SOURCE=2" && \
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless || true && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all || true && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "icu" ]; then make -j1 && make DESTDIR=/artifacts install; elif [ "$LIB_NAME" = "bzip2" ]; then make -j2 PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j2 && make DESTDIR=/artifacts install; fi && \
    mkdir -p /artifacts/usr/share/doc/$LIB_NAME && \
    find . -maxdepth 2 -type f \( -iname "license*" -o -iname "copying*" -o -iname "mit-license*" \) -exec cp -v {} /artifacts/usr/share/doc/$LIB_NAME/ \; -quit; \
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
    export CFLAGS="$CFLAGS -g0 -O1 -fstack-protector-strong -D_FORTIFY_SOURCE=2" && \
    export CXXFLAGS="$CXXFLAGS -g0 -O1 -fstack-protector-strong -D_FORTIFY_SOURCE=2" && \
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless || true && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all || true && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "icu" ]; then make -j1 && make DESTDIR=/artifacts install; elif [ "$LIB_NAME" = "bzip2" ]; then make -j2 PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j2 && make DESTDIR=/artifacts install; fi && \
    mkdir -p /artifacts/usr/share/doc/$LIB_NAME && \
    find . -maxdepth 2 -type f \( -iname "license*" -o -iname "copying*" -o -iname "mit-license*" \) -exec cp -v {} /artifacts/usr/share/doc/$LIB_NAME/ \; -quit; \
    fi && mkdir -p /artifacts/usr

FROM builder AS runtime-setup
USER root
RUN mkdir -p /runtime-root/usr /runtime-root/etc /runtime-root/var /opt/distroless
COPY --from=zlib /artifacts/usr /opt/distroless
COPY --from=brotli /artifacts/usr /opt/distroless
COPY --from=openssl /artifacts/usr /opt/distroless
COPY --from=libxcrypt /artifacts/usr /opt/distroless
RUN if [ -d /opt/distroless ] && [ "$(ls -A /opt/distroless)" ]; then cp -rv /opt/distroless/* /runtime-root/usr/; fi
ENV CACHE_BYPASS_SETUP="1779802651.522347"
RUN set -ex && curl -L "" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src && \
    export CPPFLAGS="-I/opt/distroless/include -I/opt/distroless/include/libxml2" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    export CFLAGS="$CFLAGS -g0 -O1 -fstack-protector-strong -D_FORTIFY_SOURCE=2" && \
    export CXXFLAGS="$CXXFLAGS -g0 -O1 -fstack-protector-strong -D_FORTIFY_SOURCE=2" && \
    if [ -f ./Configure ] && grep -q "Perl" ./Configure; then \
        ./Configure  -Dlocincpth="/opt/distroless/include" -Dloclibpth="/opt/distroless/lib /opt/distroless/lib64"; \
    elif [ -f ./configure ]; then ./configure --prefix=/usr ; elif [ -f ./Configure ]; then ./Configure ; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr  .; fi && \
    make -j1 && make DESTDIR=/runtime-root INSTALL_ROOT=/runtime-root install && \
    mkdir -p /runtime-root/usr/share/doc/static && \
    find . -maxdepth 2 -type f \( -iname "license*" -o -iname "copying*" -o -iname "mit-license*" \) -exec cp -v {} /runtime-root/usr/share/doc/static/ \; -quit && \
    echo '--- DIAGNOSTIC: /runtime-root contents ---' && \
    find /runtime-root -maxdepth 4 || true

RUN set -ex && mkdir -p /runtime-root/usr/lib64 && \
    cp -L /usr/lib64/libc.so.6 /runtime-root/usr/lib64/ || true && \
    cp -L /usr/lib64/libm.so.6 /runtime-root/usr/lib64/ || true && \
    cp -L /usr/lib64/librt.so.1 /runtime-root/usr/lib64/ || true && \
    cp -L /usr/lib64/libpthread.so.0 /runtime-root/usr/lib64/ || true && \
    cp -L /usr/lib64/libdl.so.2 /runtime-root/usr/lib64/ || true && \
    cp -L /usr/lib64/libresolv.so.2 /runtime-root/usr/lib64/ || true && \
    cp -L /usr/lib64/libutil.so.1 /runtime-root/usr/lib64/ || true && \
    cp -L /usr/lib64/ld-linux*.so* /runtime-root/usr/lib64/ || true

RUN set -ex && find /runtime-root/usr/bin/ /runtime-root/usr/sbin/ /runtime-root/usr/lib64/ /runtime-root/usr/lib/ -type f 2>/dev/null | while read -r file; do \
    if [ -x "$file" ] || [[ "$file" == *.so* ]]; then \
      ldd "$file" 2>/dev/null | grep "=>" | awk '{print $3}' | while read -r lib; do \
        if [ -f "$lib" ]; then \
          if [[ "$lib" == /usr/lib64/* ]] || [[ "$lib" == /lib64/* ]]; then \
            mkdir -p /runtime-root/usr/lib64 && cp -L -n "$lib" /runtime-root/usr/lib64/ || true; \
          elif [[ "$lib" == /usr/lib/* ]] || [[ "$lib" == /lib/* ]]; then \
            mkdir -p /runtime-root/usr/lib && cp -L -n "$lib" /runtime-root/usr/lib/ || true; \
          fi; \
        fi; \
      done; \
    fi; \
  done

RUN ldconfig -r /runtime-root

FROM cc AS runtime
USER root
ARG RUNTIME_NAME
ARG RUNTIME_VER
LABEL distroless.stack="${RUNTIME_NAME}"
ENV CACHE_BYPASS="1779802651.522403"
COPY --from=runtime-setup /runtime-root/usr/ /usr/
COPY --from=runtime-setup /runtime-root/etc/ /etc/
COPY --from=runtime-setup /runtime-root/var/ /var/
USER 65532:65532

FROM runtime AS runtime-debug
USER root
COPY --from=builder /usr/bin/busybox /usr/bin/busybox
RUN ["/usr/bin/busybox", "--install", "-s", "/usr/bin"]
USER 65532:65532
