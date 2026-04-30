# syntax=docker/dockerfile:1.4
FROM scratch as deps
FROM ghcr.io/mbuccarello/base-fedora:latest as builder
RUN dnf install -y gcc make autoconf automake libtool perl perl-open diffutils patch unzip
WORKDIR /build

ARG LIB_NAME
ARG LIB_URL
ARG LIB_SHA
ARG LIB_CONFIG=""
ARG LDFLAGS_EXTRA=""
ARG MAKE_EXTRA=""

# Mount dependencies from the 'deps' stage
# If not overridden by Bake, 'deps' is just an empty scratch stage
RUN --mount=type=bind,from=deps,target=/deps \
    if [ -d "/deps/usr" ]; then \
      mkdir -p /artifacts/usr && \
      cp -rn /deps/usr/* /artifacts/usr/ || true; \
    fi

RUN curl -L -o source.archive ${LIB_URL} || (echo "${LIB_URL}" | grep -q "^git+" && git clone "${LIB_URL#git+}" . ) || true

RUN if [ -n "${LIB_SHA}" ] && [ -f "source.archive" ]; then \
      if [ ${#LIB_SHA} -eq 64 ]; then \
        echo "${LIB_SHA}  source.archive" | sha256sum -c -; \
      else \
        echo "${LIB_SHA}  source.archive" | sha512sum -c -; \
      fi; \
    fi && \
    if [ -f "source.archive" ]; then \
      if [[ "${LIB_URL}" == *.zip ]]; then \
        unzip source.archive && cp -rf */* . || true; \
      else \
        tar -xf source.archive --strip-components=1 || tar -xJf source.archive --strip-components=1 || true; \
      fi; \
    fi

RUN mkdir -p /artifacts/usr
ENV CFLAGS="-O2 -fPIC -I/artifacts/usr/include -I/artifacts/usr/include/ncursesw"
RUN if [ ! -f "./configure" ] && [ -f "./autogen.sh" ]; then \
      export MAKEINFO=true && \
      ./autogen.sh; \
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
      ln -s ncursesw/term.h /artifacts/usr/include/term.h || true; \
    fi

FROM scratch
COPY --from=builder /artifacts/usr /usr
