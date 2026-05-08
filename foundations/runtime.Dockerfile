
FROM builder AS zlib
ARG LIB_NAME=zlib
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src/$LIB_SUBDIR && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all && \
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
    export CPPFLAGS="-I/opt/distroless/include" && \
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "icu" ]; then make -j1 && make DESTDIR=/artifacts install; elif [ "$LIB_NAME" = "bzip2" ]; then make -j2 PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j2 && make DESTDIR=/artifacts install; fi; \
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
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "icu" ]; then make -j1 && make DESTDIR=/artifacts install; elif [ "$LIB_NAME" = "bzip2" ]; then make -j2 PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j2 && make DESTDIR=/artifacts install; fi; \
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
    export CPPFLAGS="-I/opt/distroless/include" && \
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "icu" ]; then make -j1 && make DESTDIR=/artifacts install; elif [ "$LIB_NAME" = "bzip2" ]; then make -j2 PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j2 && make DESTDIR=/artifacts install; fi; \
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
    export CPPFLAGS="-I/opt/distroless/include" && \
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "icu" ]; then make -j1 && make DESTDIR=/artifacts install; elif [ "$LIB_NAME" = "bzip2" ]; then make -j2 PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j2 && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS libjpeg-turbo
ARG LIB_NAME=libjpeg-turbo
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src/$LIB_SUBDIR && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "icu" ]; then make -j1 && make DESTDIR=/artifacts install; elif [ "$LIB_NAME" = "bzip2" ]; then make -j2 PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j2 && make DESTDIR=/artifacts install; fi; \
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
    export CPPFLAGS="-I/opt/distroless/include" && \
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "icu" ]; then make -j1 && make DESTDIR=/artifacts install; elif [ "$LIB_NAME" = "bzip2" ]; then make -j2 PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j2 && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS libx11
ARG LIB_NAME=libx11
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src/$LIB_SUBDIR && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "icu" ]; then make -j1 && make DESTDIR=/artifacts install; elif [ "$LIB_NAME" = "bzip2" ]; then make -j2 PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j2 && make DESTDIR=/artifacts install; fi; \
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
    export CPPFLAGS="-I/opt/distroless/include" && \
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "icu" ]; then make -j1 && make DESTDIR=/artifacts install; elif [ "$LIB_NAME" = "bzip2" ]; then make -j2 PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j2 && make DESTDIR=/artifacts install; fi; \
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
    export CPPFLAGS="-I/opt/distroless/include" && \
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "icu" ]; then make -j1 && make DESTDIR=/artifacts install; elif [ "$LIB_NAME" = "bzip2" ]; then make -j2 PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j2 && make DESTDIR=/artifacts install; fi; \
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
    export CPPFLAGS="-I/opt/distroless/include" && \
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "icu" ]; then make -j1 && make DESTDIR=/artifacts install; elif [ "$LIB_NAME" = "bzip2" ]; then make -j2 PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j2 && make DESTDIR=/artifacts install; fi; \
    fi && mkdir -p /artifacts/usr

FROM builder AS alsa-lib
ARG LIB_NAME=alsa-lib
ARG LIB_URL
ARG LIB_CONFIG
ARG LIB_SUBDIR=.
WORKDIR /build
RUN set -ex && if [ -n "$LIB_URL" ] && [ "$LIB_URL" != "SKIP" ]; then \
    curl -L "$LIB_URL" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src/$LIB_SUBDIR && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all && \
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
    export CPPFLAGS="-I/opt/distroless/include" && \
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all && \
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
    export CPPFLAGS="-I/opt/distroless/include" && \
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "icu" ]; then make -j1 && make DESTDIR=/artifacts install; elif [ "$LIB_NAME" = "bzip2" ]; then make -j2 PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j2 && make DESTDIR=/artifacts install; fi; \
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
RUN set -ex && curl -L "https://github.com/openjdk/jdk21u/archive/refs/tags/jdk-21.0.11-ga.tar.gz" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./Configure ] && grep -q "Perl" ./Configure; then \
        ./Configure --with-zlib=system --with-freetype=system --with-libpng=system --with-lcms=system --with-libjpeg=system --disable-warnings-as-errors --with-native-debug-symbols=none --with-jvm-variants=server --with-debug-level=release -Dlocincpth="/opt/distroless/include" -Dloclibpth="/opt/distroless/lib /opt/distroless/lib64"; \
    elif [ -f ./configure ]; then ./configure --prefix=/usr --with-zlib=system --with-freetype=system --with-libpng=system --with-lcms=system --with-libjpeg=system --disable-warnings-as-errors --with-native-debug-symbols=none --with-jvm-variants=server --with-debug-level=release; elif [ -f ./Configure ]; then ./Configure --with-zlib=system --with-freetype=system --with-libpng=system --with-lcms=system --with-libjpeg=system --disable-warnings-as-errors --with-native-debug-symbols=none --with-jvm-variants=server --with-debug-level=release; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr --with-zlib=system --with-freetype=system --with-libpng=system --with-lcms=system --with-libjpeg=system --disable-warnings-as-errors --with-native-debug-symbols=none --with-jvm-variants=server --with-debug-level=release .; fi && \
    export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0 -O1" && \
    export CFLAGS="$CFLAGS -g0 -O1" && \
    make -j1 && make DESTDIR=/runtime-root install

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
