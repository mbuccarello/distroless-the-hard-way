# syntax=docker/dockerfile:1.4
FROM scratch as deps
FROM ghcr.io/mbuccarello/base-fedora:latest as builder
RUN dnf install -y gcc make autoconf automake libtool perl perl-open diffutils patch unzip git gettext gettext-devel pkgconf-pkg-config m4 bison flex texinfo po4a
WORKDIR /build

ARG LIB_NAME
ARG LIB_URL
ARG LIB_SHA
ARG LIB_CONFIG
ARG MAKE_EXTRA

COPY --from=deps / /artifacts/

RUN if [[ "${LIB_URL}" == git+* ]]; then \
      URL="${LIB_URL#git+}" && \
      TAG=$(echo "${URL}" | grep -oP '(?<=#tag=)[^?]+' || echo "${URL}" | grep -oP '(?<=#branch=)[^?]+' || echo "") && \
      BASE_URL=$(echo "${URL}" | cut -d'#' -f1 | cut -d'?' -f1) && \
      git clone "${BASE_URL}" . && \
      if [ -n "${TAG}" ]; then git checkout "${TAG}"; fi; \
    else \
      curl -L -o source.archive "${LIB_URL}" && \
      if [ -n "${LIB_SHA}" ]; then \
        if [ ${#LIB_SHA} -eq 64 ]; then \
          echo "${LIB_SHA}  source.archive" | sha256sum -c -; \
        else \
          echo "${LIB_SHA}  source.archive" | sha512sum -c -; \
        fi; \
      fi && \
      if [[ "${LIB_URL}" == *.zip ]]; then \
        unzip source.archive && cp -rf */* . || true; \
      else \
        tar -xf source.archive --strip-components=1 || tar -xJf source.archive --strip-components=1 || true; \
      fi; \
    fi

RUN mkdir -p /artifacts/usr/lib /artifacts/usr/include
ENV CFLAGS="-O2 -fPIC -I/artifacts/usr/include -I/artifacts/usr/include/ncursesw"
ENV LDFLAGS="-L/artifacts/usr/lib -L/artifacts/usr/lib64"
ENV PKG_CONFIG_PATH="/artifacts/usr/lib/pkgconfig:/artifacts/usr/lib64/pkgconfig"

RUN if [ ! -f "./configure" ]; then \
      if [ -f "./autogen.sh" ]; then ./autogen.sh; \
      elif [ -f "./autogen" ]; then ./autogen; \
      elif [ -f "configure.ac" ] || [ -f "configure.in" ]; then autoreconf -fi; \
      fi; \
    fi && \
    if [ -f "./configure" ]; then \
      ./configure --prefix=/usr --libdir=/usr/lib64 ${LIB_CONFIG} || (cat config.log && exit 1) && \
      eval make -j$(nproc) ${MAKE_EXTRA} || (eval make V=1 ${MAKE_EXTRA} && exit 1) && \
      eval make install DESTDIR=/artifacts ${MAKE_EXTRA}; \
    elif [ "${LIB_NAME}" = "openssl" ]; then \
      ./Configure --prefix=/usr --libdir=lib64 ${LIB_CONFIG} && \
      make -j$(nproc) && \
      make install_sw DESTDIR=/artifacts; \
    elif [ "${LIB_NAME}" = "bzip2" ]; then \
      make -f Makefile-libbz2_so && \
      make install PREFIX=/artifacts/usr && \
      mkdir -p /artifacts/usr/lib64 && \
      cp -a libbz2.so* /artifacts/usr/lib64/; \
    else \
      make -j$(nproc) PREFIX=/usr CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" && \
      make install PREFIX=/usr DESTDIR=/artifacts CFLAGS="${CFLAGS}"; \
    fi

RUN if [ "${LIB_NAME}" = "ncurses" ]; then \
      ln -s ncursesw/ncurses.h /artifacts/usr/include/ncurses.h || true && \
      ln -s ncursesw/curses.h /artifacts/usr/include/curses.h || true && \
      ln -s ncursesw/term.h /artifacts/usr/include/term.h || true && \
      for lib in ncurses ncurses++ form panel menu tic tinfo; do \
        ln -s lib${lib}w.so /artifacts/usr/lib64/lib${lib}.so || true; \
      done; \
    fi && \
    if [ "${LIB_NAME}" = "python" ]; then \
      ln -s python3.14 /artifacts/usr/bin/python3 || true; \
      ln -s python3.14 /artifacts/usr/bin/python3.12 || true; \
    fi

FROM scratch
COPY --from=builder /artifacts/usr /usr
