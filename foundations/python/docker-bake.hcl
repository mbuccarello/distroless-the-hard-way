group "default" {
  targets = ["ncurses", "readline", "openssl", "sqlite", "libffi", "bzip2", "xz", "zlib", "libxcrypt", "expat", "gdbm", "python", "consolidated"]
}

variable "REGISTRY" { default = "ghcr.io/mbuccarello" }

target "foundation-base" {
  dockerfile = "Dockerfile"
  context = "."
}

target "ncurses" {
  inherits = ["foundation-base"]
  args = {
    LIB_NAME = "ncurses"
    LIB_URL = "git+https://github.com/ThomasDickey/ncurses-snapshots.git?signed#tag=v6_6"
    LIB_SHA = "cad17bf83ef3ccd71fb7c33933ddbbbef2e8bd050d5e4e4ebb344b5df8292b1cd3c9e1787e88087d73cc96f625ba0c7cd6714d7720af7f8bd50b314e9838d2a7"
    LIB_CONFIG = "--with-shared --with-cxx-shared --enable-widec --without-debug --without-normal --with-termlib"
  }
  tags = ["${REGISTRY}/foundation-python-ncurses:latest"]
}

target "readline" {
  inherits = ["foundation-base"]
  args = {
    LIB_NAME = "readline"
    LIB_URL = "https://ftp.gnu.org/gnu/readline/readline-8.3.tar.gz"
    LIB_CONFIG = "--with-curses"
    MAKE_EXTRA = "SHLIB_LIBS=\"-lncursesw -ltinfo\""
  }
  contexts = {
    deps = "target:ncurses"
    ncurses = "target:ncurses"
  }
  tags = ["${REGISTRY}/foundation-python-readline:latest"]
}

target "openssl" {
  inherits = ["foundation-base"]
  args = {
    LIB_NAME = "openssl"
    LIB_URL = "https://github.com/openssl/openssl/releases/download/openssl-3.6.2/openssl-3.6.2.tar.gz"
  }
  contexts = {
    deps = "target:zlib"
    zlib = "target:zlib"
  }
  tags = ["${REGISTRY}/foundation-python-openssl:latest"]
}

target "sqlite" {
  inherits = ["foundation-base"]
  args = {
    LIB_NAME = "sqlite"
    LIB_URL = "https://www.sqlite.org/2026/sqlite-src-3530000.zip"
  }
  contexts = {
    deps = "target:zlib"
    zlib = "target:zlib"
    deps = "target:readline"
    readline = "target:readline"
    deps = "target:ncurses"
    ncurses = "target:ncurses"
  }
  tags = ["${REGISTRY}/foundation-python-sqlite:latest"]
}

target "libffi" {
  inherits = ["foundation-base"]
  args = {
    LIB_NAME = "libffi"
    LIB_URL = "https://github.com/libffi/libffi/archive/refs/tags/v3.5.2.tar.gz"
    LIB_CONFIG = "--disable-multi-os-directory"
  }
  tags = ["${REGISTRY}/foundation-python-libffi:latest"]
}

target "bzip2" {
  inherits = ["foundation-base"]
  args = {
    LIB_NAME = "bzip2"
    LIB_URL = "https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz"
  }
  tags = ["${REGISTRY}/foundation-python-bzip2:latest"]
}

target "xz" {
  inherits = ["foundation-base"]
  args = {
    LIB_NAME = "xz"
    LIB_URL = "git+https://github.com/tukaani-project/xz#tag=v5.8.3?signed"
    LIB_SHA = "47f7d0cdd200c0db0bee0cf5d1419993d02219ee7c52dc3ea017a9b6af5c2dc5c0d80eab485715f2eb7016829ad14963e836bf07b32b11b9743fd933df2476d0"
  }
  tags = ["${REGISTRY}/foundation-python-xz:latest"]
}

target "zlib" {
  inherits = ["foundation-base"]
  args = {
    LIB_NAME = "zlib"
    LIB_URL = "https://github.com/madler/zlib/releases/download/v1.3.2/zlib-1.3.2.tar.xz"
    LIB_SHA = "cf3d49fbabddc57cca99858feeca8f910e9de42a16014cddd406814d2d24ee33fee2af3805d7efbb1b04b05f55818092b000daf82502b675df65f2512c353f73"
  }
  tags = ["${REGISTRY}/foundation-python-zlib:latest"]
}

target "libxcrypt" {
  inherits = ["foundation-base"]
  args = {
    LIB_NAME = "libxcrypt"
    LIB_URL = "https://github.com/besser82/libxcrypt/releases/download/v4.5.2/libxcrypt-4.5.2.tar.xz"
    LIB_CONFIG = "--disable-obsolete-api --disable-werror"
  }
  tags = ["${REGISTRY}/foundation-python-libxcrypt:latest"]
}

target "expat" {
  inherits = ["foundation-base"]
  args = {
    LIB_NAME = "expat"
    LIB_URL = "https://github.com/libexpat/libexpat/releases/download/R_2_6_2/expat-2.6.2.tar.bz2"
  }
  tags = ["${REGISTRY}/foundation-python-expat:latest"]
}

target "gdbm" {
  inherits = ["foundation-base"]
  args = {
    LIB_NAME = "gdbm"
    LIB_URL = "https://ftp.gnu.org/gnu/gdbm/gdbm-1.23.tar.gz"
  }
  tags = ["${REGISTRY}/foundation-python-gdbm:latest"]
}

target "python" {
  inherits = ["foundation-base"]
  args = {
    LIB_NAME = "python"
    LIB_URL = "https://www.python.org/ftp/python/3.14.4/Python-3.14.4.tar.xz"
    LIB_SHA = "89a7f8b8a31f48d150badb4751df137d47d9014c9c422649a1a55aef5618aa7f0259dd18c151e6804fa8312c6a21544332a9f630ee81150dc00505637e62bb8c"
    LIB_CONFIG = "--enable-shared --with-system-ffi --with-system-expat --enable-optimizations --with-lto --enable-loadable-sqlite-extensions --without-ensurepip"
  }
  contexts = {
    deps = "target:ncurses"
    ncurses = "target:ncurses"
    deps = "target:readline"
    readline = "target:readline"
    deps = "target:openssl"
    openssl = "target:openssl"
    deps = "target:sqlite"
    sqlite = "target:sqlite"
    deps = "target:libffi"
    libffi = "target:libffi"
    deps = "target:bzip2"
    bzip2 = "target:bzip2"
    deps = "target:xz"
    xz = "target:xz"
    deps = "target:zlib"
    zlib = "target:zlib"
    deps = "target:libxcrypt"
    libxcrypt = "target:libxcrypt"
    deps = "target:expat"
    expat = "target:expat"
    deps = "target:gdbm"
    gdbm = "target:gdbm"
  }
  tags = ["${REGISTRY}/foundation-python-python:latest"]
}

target "consolidated" {
  dockerfile = "Dockerfile.consolidated"
  context = "."
  contexts = {
    ncurses = "target:ncurses"
    readline = "target:readline"
    openssl = "target:openssl"
    sqlite = "target:sqlite"
    libffi = "target:libffi"
    bzip2 = "target:bzip2"
    xz = "target:xz"
    zlib = "target:zlib"
    libxcrypt = "target:libxcrypt"
    expat = "target:expat"
    gdbm = "target:gdbm"
  }
  tags = ["${REGISTRY}/foundation-python-consolidated:latest"]
}

target "runtime" {
  dockerfile = "Dockerfile.runtime"
  context = "."
  contexts = {
    python = "target:python"
    consolidated = "target:consolidated"
  }
  tags = ["${REGISTRY}/python-distroless:3.12-sovereign"]
}
