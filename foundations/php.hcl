variable "REGISTRY" {
  default = "ghcr.io/mbuccarello"
}

variable "ATOMS_REGISTRY" {
  default = "ghcr.io/mbuccarello/atoms"
}

group "default" {
  targets = ["runtime", "runtime-debug"]
}

target "foundations" {
  dockerfile = "foundations/builder.Dockerfile"
  context = "."
}

target "zlib" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "zlib"
  context = "."
  platforms = ["linux/amd64"]
  tags = ["${ATOMS_REGISTRY}/zlib:1.3.2"]
  args = {
    LIB_NAME = "zlib"
    LIB_URL = "https://github.com/madler/zlib/archive/refs/tags/v1.3.1.tar.gz"
    LIB_CONFIG = "--shared"
  }
  contexts = {
    builder = "target:foundations"
  }
}

target "brotli" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "brotli"
  context = "."
  platforms = ["linux/amd64"]
  tags = ["${ATOMS_REGISTRY}/brotli:1.2.0"]
  args = {
    LIB_NAME = "brotli"
    LIB_URL = "https://github.com/google/brotli/archive/refs/tags/v1.1.0.tar.gz"
  }
  contexts = {
    builder = "target:foundations"
  }
}

target "openssl" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "openssl"
  context = "."
  platforms = ["linux/amd64"]
  tags = ["${ATOMS_REGISTRY}/openssl:3.6.2"]
  args = {
    LIB_NAME = "openssl"
    LIB_URL = "https://github.com/openssl/openssl/releases/download/openssl-3.4.0/openssl-3.4.0.tar.gz"
    LIB_CONFIG = "shared zlib"
  }
  contexts = {
    builder = "target:foundations"
    brotli = "target:brotli"
    zlib = "target:zlib"
  }
}

target "icu" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "icu"
  context = "."
  platforms = ["linux/amd64"]
  tags = ["${ATOMS_REGISTRY}/icu:78.3"]
  args = {
    LIB_NAME = "icu"
    LIB_URL = "https://github.com/unicode-org/icu/releases/download/release-75-1/icu4c-75_1-src.tgz"
    LIB_CONFIG = "--enable-static --enable-shared --disable-tests --disable-samples --disable-extras --disable-icuio --disable-layoutex --disable-tools"
    LIB_SUBDIR = "source"
  }
  contexts = {
    builder = "target:foundations"
  }
}

target "ncurses" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "ncurses"
  context = "."
  platforms = ["linux/amd64"]
  tags = ["${ATOMS_REGISTRY}/ncurses:6.6"]
  args = {
    LIB_NAME = "ncurses"
    LIB_URL = "https://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.5.tar.gz"
    LIB_CONFIG = "--with-shared --enable-widec --enable-pc-files --with-termlib"
  }
  contexts = {
    builder = "target:foundations"
  }
}

target "readline" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "readline"
  context = "."
  platforms = ["linux/amd64"]
  tags = ["${ATOMS_REGISTRY}/readline:8.3.3"]
  args = {
    LIB_NAME = "readline"
    LIB_URL = "https://ftp.gnu.org/pub/gnu/readline/readline-8.2.tar.gz"
    LIB_CONFIG = "--with-curses"
  }
  contexts = {
    builder = "target:foundations"
    ncurses = "target:ncurses"
  }
}

target "libxml2" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "libxml2"
  context = "."
  platforms = ["linux/amd64"]
  tags = ["${ATOMS_REGISTRY}/libxml2:2.15.3"]
  args = {
    LIB_NAME = "libxml2"
    LIB_URL = "https://download.gnome.org/sources/libxml2/2.12/libxml2-2.12.9.tar.xz"
    LIB_CONFIG = "--without-python --without-icu"
  }
  contexts = {
    builder = "target:foundations"
    icu = "target:icu"
    readline = "target:readline"
    zlib = "target:zlib"
  }
}

target "sqlite" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "sqlite"
  context = "."
  platforms = ["linux/amd64"]
  tags = ["${ATOMS_REGISTRY}/sqlite:3.53.1"]
  args = {
    LIB_NAME = "sqlite"
    LIB_URL = "https://www.sqlite.org/2024/sqlite-autoconf-3470000.tar.gz"
  }
  contexts = {
    builder = "target:foundations"
    readline = "target:readline"
    zlib = "target:zlib"
  }
}

target "oniguruma" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "oniguruma"
  context = "."
  platforms = ["linux/amd64"]
  tags = ["${ATOMS_REGISTRY}/oniguruma:6.9.10"]
  args = {
    LIB_NAME = "oniguruma"
    LIB_URL = "https://github.com/kkos/oniguruma/releases/download/v6.9.9/onig-6.9.9.tar.gz"
    LIB_CONFIG = "--enable-shared"
  }
  contexts = {
    builder = "target:foundations"
  }
}

target "krb5" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "krb5"
  context = "."
  platforms = ["linux/amd64"]
  tags = ["${ATOMS_REGISTRY}/krb5:1.21.3"]
  args = {
    LIB_NAME = "krb5"
    LIB_URL = "https://web.mit.edu/kerberos/dist/krb5/1.21/krb5-1.21.3.tar.gz"
    LIB_CONFIG = "--with-crypto-impl=openssl --with-system-verto=no --disable-rpath"
    LIB_SUBDIR = "src"
  }
  contexts = {
    builder = "target:foundations"
    openssl = "target:openssl"
  }
}

target "curl" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "curl"
  context = "."
  platforms = ["linux/amd64"]
  tags = ["${ATOMS_REGISTRY}/curl:8.20.0"]
  args = {
    LIB_NAME = "curl"
    LIB_URL = "https://github.com/curl/curl/releases/download/curl-8_11_0/curl-8.11.0.tar.gz"
    LIB_CONFIG = "--with-openssl=/opt/distroless --with-zlib=/opt/distroless --with-nghttp2=/opt/distroless --with-ca-bundle=/etc/ssl/certs/ca-certificates.crt"
  }
  contexts = {
    builder = "target:foundations"
    brotli = "target:brotli"
    krb5 = "target:krb5"
    zlib = "target:zlib"
  }
}

target "libxcrypt" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "libxcrypt"
  context = "."
  platforms = ["linux/amd64"]
  tags = ["${ATOMS_REGISTRY}/libxcrypt:4.5.2"]
  args = {
    LIB_NAME = "libxcrypt"
    LIB_URL = "https://github.com/besser82/libxcrypt/releases/download/v4.4.36/libxcrypt-4.4.36.tar.xz"
    LIB_CONFIG = "--disable-werror --enable-hashes=all --enable-obsolete-api=no"
  }
  contexts = {
    builder = "target:foundations"
  }
}

target "bzip2" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "bzip2"
  context = "."
  platforms = ["linux/amd64"]
  tags = ["${ATOMS_REGISTRY}/bzip2:1.0.8"]
  args = {
    LIB_NAME = "bzip2"
    LIB_URL = "https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz"
  }
  contexts = {
    builder = "target:foundations"
  }
}

target "pcre2" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "pcre2"
  context = "."
  platforms = ["linux/amd64"]
  tags = ["${ATOMS_REGISTRY}/pcre2:10.47"]
  args = {
    LIB_NAME = "pcre2"
    LIB_URL = "https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.44/pcre2-10.44.tar.gz"
    LIB_CONFIG = "--enable-jit --enable-unicode"
  }
  contexts = {
    builder = "target:foundations"
    bzip2 = "target:bzip2"
    readline = "target:readline"
    zlib = "target:zlib"
  }
}

target "cc-php" {
  dockerfile = "foundations/cc-php.Dockerfile"
  target = "cc"
  context = "."
  contexts = {
    builder = "target:foundations"
    base = "docker-image://${REGISTRY}/base:latest"
    zlib = "target:zlib"
    brotli = "target:brotli"
    openssl = "target:openssl"
    icu = "target:icu"
    ncurses = "target:ncurses"
    readline = "target:readline"
    libxml2 = "target:libxml2"
    sqlite = "target:sqlite"
    oniguruma = "target:oniguruma"
    krb5 = "target:krb5"
    curl = "target:curl"
    libxcrypt = "target:libxcrypt"
    bzip2 = "target:bzip2"
    pcre2 = "target:pcre2"
  }
}

target "runtime" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "runtime"
  context = "."
  args = {
    RUNTIME_NAME = "php"
    RUNTIME_VER = "8.3"
    RUNTIME_URL = "DNF"
  }
  contexts = {
    cc = "target:cc-php"
    builder = "target:foundations"
    zlib = "target:zlib"
    brotli = "target:brotli"
    openssl = "target:openssl"
    icu = "target:icu"
    ncurses = "target:ncurses"
    readline = "target:readline"
    libxml2 = "target:libxml2"
    sqlite = "target:sqlite"
    oniguruma = "target:oniguruma"
    krb5 = "target:krb5"
    curl = "target:curl"
    libxcrypt = "target:libxcrypt"
    bzip2 = "target:bzip2"
    pcre2 = "target:pcre2"
  }
  tags = ["${REGISTRY}/php-distroless:latest"]
}

target "runtime-debug" {
  inherits = ["runtime"]
  target = "runtime-debug"
  tags = ["${REGISTRY}/php-distroless:debug"]
}
