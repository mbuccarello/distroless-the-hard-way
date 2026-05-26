
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

FROM builder AS bzip2
ARG LIB_NAME=bzip2
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

FROM builder AS libpng
ARG LIB_NAME=libpng
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
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

FROM builder AS freetype2
ARG LIB_NAME=freetype2
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
COPY --from=brotli /artifacts/usr /opt/distroless
COPY --from=bzip2 /artifacts/usr /opt/distroless
COPY --from=libpng /artifacts/usr /opt/distroless
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

FROM builder AS libjpeg-turbo
ARG LIB_NAME=libjpeg-turbo
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

FROM builder AS lcms2
ARG LIB_NAME=lcms2
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
COPY --from=libjpeg-turbo /artifacts/usr /opt/distroless
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

FROM builder AS libx11
ARG LIB_NAME=libx11
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

FROM builder AS libxext
ARG LIB_NAME=libxext
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
COPY --from=libx11 /artifacts/usr /opt/distroless
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

FROM builder AS libxrender
ARG LIB_NAME=libxrender
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
COPY --from=libx11 /artifacts/usr /opt/distroless
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

FROM builder AS libxtst
ARG LIB_NAME=libxtst
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
COPY --from=libxext /artifacts/usr /opt/distroless
COPY --from=libx11 /artifacts/usr /opt/distroless
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

FROM builder AS alsa-lib
ARG LIB_NAME=alsa-lib
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
COPY --from=bzip2 /artifacts/usr /opt/distroless
COPY --from=libpng /artifacts/usr /opt/distroless
COPY --from=freetype2 /artifacts/usr /opt/distroless
COPY --from=libjpeg-turbo /artifacts/usr /opt/distroless
COPY --from=lcms2 /artifacts/usr /opt/distroless
COPY --from=libx11 /artifacts/usr /opt/distroless
COPY --from=libxext /artifacts/usr /opt/distroless
COPY --from=libxrender /artifacts/usr /opt/distroless
COPY --from=libxtst /artifacts/usr /opt/distroless
COPY --from=alsa-lib /artifacts/usr /opt/distroless
COPY --from=openssl /artifacts/usr /opt/distroless
COPY --from=libxcrypt /artifacts/usr /opt/distroless
RUN if [ -d /opt/distroless ] && [ "$(ls -A /opt/distroless)" ]; then cp -rv /opt/distroless/* /runtime-root/usr/; fi
ARG RUNTIME_NAME=java
ARG RUNTIME_URL
RUN set -ex && mkdir -p /tmp/extract && \
    if [ "$RUNTIME_URL" = "DNF" ]; then \
      dnf clean all && dnf install -y --setopt=install_weak_deps=False $RUNTIME_NAME $RUNTIME_NAME-fpm $RUNTIME_NAME-mysqlnd $RUNTIME_NAME-opcache $RUNTIME_NAME-xml $RUNTIME_NAME-mbstring $RUNTIME_NAME-gd $RUNTIME_NAME-curl || dnf install -y $RUNTIME_NAME && \
      if [ "$RUNTIME_NAME" = "php" ]; then dnf install -y php-cli; fi && \
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
ENV CACHE_BYPASS="1779820802.026845"
COPY --from=runtime-setup /runtime-root/usr/ /usr/
COPY --from=runtime-setup /runtime-root/etc/ /etc/
USER 65532:65532

FROM runtime AS runtime-debug
USER root
COPY --from=builder /usr/bin/busybox /usr/bin/busybox
RUN ["/usr/bin/busybox", "--install", "-s", "/usr/bin"]
USER 65532:65532
