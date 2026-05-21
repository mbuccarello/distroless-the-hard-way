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

target "libffi" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "libffi"
  context = "."
  platforms = ["linux/amd64"]
  tags = ["${ATOMS_REGISTRY}/libffi:3.5.2"]
  args = {
    LIB_NAME = "libffi"
    LIB_URL = "https://github.com/libffi/libffi/releases/download/v3.4.6/libffi-3.4.6.tar.gz"
  }
  contexts = {
    builder = "target:foundations"
  }
}

target "expat" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "expat"
  context = "."
  platforms = ["linux/amd64"]
  tags = ["${ATOMS_REGISTRY}/expat:2.8.1"]
  args = {
    LIB_NAME = "expat"
    LIB_URL = "https://github.com/libexpat/libexpat/releases/download/R_2_6_4/expat-2.6.4.tar.xz"
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

target "xz" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "xz"
  context = "."
  platforms = ["linux/amd64"]
  tags = ["${ATOMS_REGISTRY}/xz:5.8.3"]
  args = {
    LIB_NAME = "xz"
    LIB_URL = "https://github.com/tukaani-project/xz/releases/download/v5.6.3/xz-5.6.3.tar.xz"
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

target "runtime" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "runtime"
  context = "."
  args = {
    RUNTIME_NAME = "python"
    RUNTIME_VER = "3.14"
    RUNTIME_URL = "https://github.com/indygreg/python-build-standalone/releases/download/20241016/cpython-3.13.0+20241016-x86_64-unknown-linux-gnu-install_only.tar.gz"
  }
  contexts = {
    cc = "docker-image://${REGISTRY}/cc:latest"
    builder = "target:foundations"
    zlib = "target:zlib"
    brotli = "target:brotli"
    openssl = "target:openssl"
    libxcrypt = "target:libxcrypt"
    libffi = "target:libffi"
    expat = "target:expat"
    bzip2 = "target:bzip2"
    xz = "target:xz"
    ncurses = "target:ncurses"
    readline = "target:readline"
    sqlite = "target:sqlite"
  }
  tags = ["${REGISTRY}/python-distroless:latest"]
}

target "runtime-debug" {
  inherits = ["runtime"]
  target = "runtime-debug"
  tags = ["${REGISTRY}/python-distroless:debug"]
}
