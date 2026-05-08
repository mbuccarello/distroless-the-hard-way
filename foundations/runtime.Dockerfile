
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

FROM builder AS ncurses
ARG LIB_NAME=ncurses
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
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "icu" ]; then make -j1 && make DESTDIR=/artifacts install; elif [ "$LIB_NAME" = "bzip2" ]; then make -j2 PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j2 && make DESTDIR=/artifacts install; fi; \
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
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "icu" ]; then make -j1 && make DESTDIR=/artifacts install; elif [ "$LIB_NAME" = "bzip2" ]; then make -j2 PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j2 && make DESTDIR=/artifacts install; fi; \
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
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "icu" ]; then make -j1 && make DESTDIR=/artifacts install; elif [ "$LIB_NAME" = "bzip2" ]; then make -j2 PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j2 && make DESTDIR=/artifacts install; fi; \
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
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "icu" ]; then make -j1 && make DESTDIR=/artifacts install; elif [ "$LIB_NAME" = "bzip2" ]; then make -j2 PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j2 && make DESTDIR=/artifacts install; fi; \
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
    if [ "$LIB_NAME" = "icu" ]; then export CC=clang; export CXX=clang++; export CXXFLAGS="$CXXFLAGS -fno-var-tracking-assignments -g0"; fi && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    echo '--- DEBUG: Contents of /opt/distroless ---' && ls -R /opt/distroless && \
    echo '--- DEBUG: Available pkg-config packages ---' && pkg-config --list-all && \
    if [ -f ./configure ]; then ./configure --prefix=/usr $LIB_CONFIG; elif [ -f ./Configure ]; then ./Configure --prefix=/usr $LIB_CONFIG; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr $LIB_CONFIG .; fi && \
    if [ "$LIB_NAME" = "icu" ]; then make -j1 && make DESTDIR=/artifacts install; elif [ "$LIB_NAME" = "bzip2" ]; then make -j2 PREFIX=/usr && make DESTDIR=/artifacts PREFIX=/usr install; else make -j2 && make DESTDIR=/artifacts install; fi; \
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
RUN set -ex && curl -L "https://www.php.net/distributions/php-8.3.13.tar.gz" -o source.tar.gz && mkdir src && tar -xf source.tar.gz -C src --strip-components=1 && cd src && \
    export CPPFLAGS="-I/opt/distroless/include" && \
    export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib" && \
    export PKG_CONFIG_PATH="/opt/distroless/lib/pkgconfig:/opt/distroless/lib64/pkgconfig" && \
    if [ -f ./Configure ] && grep -q "Perl" ./Configure; then \
        ./Configure --with-openssl=/opt/distroless --with-zlib=/opt/distroless --with-curl=/opt/distroless --with-libxml=/opt/distroless --with-sqlite3=/opt/distroless --with-pdo-sqlite=/opt/distroless --with-onig=/opt/distroless --with-pcre-dir=/opt/distroless --enable-fpm --enable-mbstring --enable-bcmath --enable-xml --enable-pcntl --with-config-file-path=/etc/php --with-config-file-scan-dir=/etc/php/conf.d -Dlocincpth="/opt/distroless/include" -Dloclibpth="/opt/distroless/lib /opt/distroless/lib64"; \
    elif [ -f ./configure ]; then ./configure --prefix=/usr --with-openssl=/opt/distroless --with-zlib=/opt/distroless --with-curl=/opt/distroless --with-libxml=/opt/distroless --with-sqlite3=/opt/distroless --with-pdo-sqlite=/opt/distroless --with-onig=/opt/distroless --with-pcre-dir=/opt/distroless --enable-fpm --enable-mbstring --enable-bcmath --enable-xml --enable-pcntl --with-config-file-path=/etc/php --with-config-file-scan-dir=/etc/php/conf.d; elif [ -f ./Configure ]; then ./Configure --with-openssl=/opt/distroless --with-zlib=/opt/distroless --with-curl=/opt/distroless --with-libxml=/opt/distroless --with-sqlite3=/opt/distroless --with-pdo-sqlite=/opt/distroless --with-onig=/opt/distroless --with-pcre-dir=/opt/distroless --enable-fpm --enable-mbstring --enable-bcmath --enable-xml --enable-pcntl --with-config-file-path=/etc/php --with-config-file-scan-dir=/etc/php/conf.d; elif [ -f ./CMakeLists.txt ]; then cmake -DCMAKE_INSTALL_PREFIX=/usr --with-openssl=/opt/distroless --with-zlib=/opt/distroless --with-curl=/opt/distroless --with-libxml=/opt/distroless --with-sqlite3=/opt/distroless --with-pdo-sqlite=/opt/distroless --with-onig=/opt/distroless --with-pcre-dir=/opt/distroless --enable-fpm --enable-mbstring --enable-bcmath --enable-xml --enable-pcntl --with-config-file-path=/etc/php --with-config-file-scan-dir=/etc/php/conf.d .; fi && \
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
