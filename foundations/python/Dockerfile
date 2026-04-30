# syntax=docker/dockerfile:1.4
FROM scratch as deps
FROM ghcr.io/mbuccarello/base-fedora:latest as builder
RUN dnf install -y gcc make autoconf automake libtool perl perl-open diffutils patch
WORKDIR /build

ARG LIB_NAME
ARG LIB_URL
ARG LIB_SHA
ARG LIB_CONFIG=""
ARG LDFLAGS_EXTRA=""

# Mount dependencies from the 'deps' stage
# If not overridden by Bake, 'deps' is just an empty scratch stage
RUN --mount=type=bind,from=deps,target=/deps \
    if [ -d "/deps/usr" ]; then \
      mkdir -p /artifacts/usr && \
      cp -rn /deps/usr/* /artifacts/usr/ || true; \
    fi

RUN curl -L -o source.tar.gz ${LIB_URL} && \
    echo "${LIB_SHA}  source.tar.gz" | sha256sum -c - && \
    tar -xzf source.tar.gz --strip-components=1 || tar -xJf source.tar.gz --strip-components=1

RUN mkdir -p /artifacts/usr
ENV CFLAGS="-O2 -fPIC -I/artifacts/usr/include"
ENV CXXFLAGS="-O2 -fPIC -I/artifacts/usr/include"
ENV LDFLAGS="-L/artifacts/usr/lib64 -L/artifacts/usr/lib ${LDFLAGS_EXTRA}"

RUN if [ -f "./configure" ]; then \
      ./configure --prefix=/usr --libdir=/usr/lib64 ${LIB_CONFIG} || (cat config.log && exit 1) && \
      make -j$(nproc) || (make V=1 && exit 1) && \
      make install DESTDIR=/artifacts; \
    elif [ "${LIB_NAME}" = "bzip2" ]; then \
      make -f Makefile-libbz2_so && \
      make install PREFIX=/artifacts/usr && \
      cp -a libbz2.so* /artifacts/usr/lib/ || cp -a libbz2.so* /artifacts/usr/lib64/; \
    else \
      make -j$(nproc) PREFIX=/usr CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" && \
      make install PREFIX=/usr DESTDIR=/artifacts CFLAGS="${CFLAGS}"; \
    fi

# Apply "Arch Linux Intelligence" for ncurses to solve readline crashes
RUN if [ "${LIB_NAME}" = "ncurses" ]; then \
      ln -s ncursesw/ncurses.h /artifacts/usr/include/ncurses.h || true && \
      ln -s ncursesw/term.h /artifacts/usr/include/term.h || true && \
      # Linker scripts for tinfo/ncurses as per Arch Intelligence
      echo "INPUT(libncursesw.so.6)" > /artifacts/usr/lib64/libncurses.so && \
      echo "INPUT(libncursesw.so.6)" > /artifacts/usr/lib64/libtinfo.so && \
      ln -s libncursesw.so.6 /artifacts/usr/lib64/libncurses.so.6 || true && \
      ln -s libncursesw.so.6 /artifacts/usr/lib64/libtinfo.so.6 || true; \
    fi

FROM scratch
COPY --from=builder /artifacts/usr /usr
