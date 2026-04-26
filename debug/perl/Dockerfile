FROM ghcr.io/mbuccarello/base-fedora:latest as builder
RUN dnf install -y gcc make autoconf bison pkgconfig

WORKDIR /build
# Target Perl 5.38.2 (Stable)
RUN curl -L -o perl.tar.gz https://www.cpan.org/src/5.0/perl-5.38.2.tar.gz
RUN tar -xzf perl.tar.gz --strip-components=1

# Pull sovereign foundations
COPY --from=ghcr.io/mbuccarello/foundation-libxcrypt:latest / /artifacts/

# Documentation-driven Configure for relocatable Perl
# We use -Dccdlflags to ensure RPATH is baked into the binary and modules
RUN sh Configure -des \
    -Dprefix=/usr/local \
    -Duseshrplib \
    -Dusethreads \
    -Dlibpth='/artifacts/lib /usr/lib64 /lib64 /lib' \
    -Accflags='-I/artifacts/include' \
    -Aldflags='-Wl,-rpath,/usr/local/lib:/artifacts/lib:/lib64:/lib -L/artifacts/lib' \
    -Dccdlflags='-Wl,-rpath,/usr/local/lib:/artifacts/lib:/lib64:/lib'
RUN make -j$(nproc)
RUN make install DESTDIR=/rootfs

FROM scratch
COPY --from=ghcr.io/mbuccarello/base:latest / /
COPY --from=ghcr.io/mbuccarello/foundation-libxcrypt:latest /lib/. /usr/local/lib/
COPY --from=ghcr.io/mbuccarello/foundation-libxcrypt:latest /include/. /usr/local/include/
COPY --from=builder /rootfs/usr/local /usr/local/

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LANG=C.UTF-8
ENTRYPOINT ["/usr/local/bin/perl"]
CMD ["--version"]
