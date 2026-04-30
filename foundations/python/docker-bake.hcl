group "default" {
  targets = ["ncurses", "readline", "openssl", "sqlite", "libffi", "bzip2", "xz", "zlib", "consolidated"]
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
  }
  tags = ["${REGISTRY}/foundation-python-ncurses:latest"]
}

target "readline" {
  inherits = ["foundation-base"]
  args = {
    LIB_NAME = "readline"
    LIB_URL = "https://ftp.gnu.org/gnu/readline/readline-8.3.tar.gz"
    LIB_SHA = "45d6fe7e34c56d309102a94aa776a7f5284201e844450e14ff818df9fa84a72154bdca70f11828c94954b080cbbe4666fa0b00ffa8460118ec8f3ea551b73dad"
  }
  tags = ["${REGISTRY}/foundation-python-readline:latest"]
}

target "openssl" {
  inherits = ["foundation-base"]
  args = {
    LIB_NAME = "openssl"
    LIB_URL = "https://github.com/openssl/openssl/releases/download/openssl-3.6.2/openssl-3.6.2.tar.gz"
  }
  tags = ["${REGISTRY}/foundation-python-openssl:latest"]
}

target "sqlite" {
  inherits = ["foundation-base"]
  args = {
    LIB_NAME = "sqlite"
    LIB_URL = "https://www.sqlite.org/2026/sqlite-src-3530000.zip"
  }
  tags = ["${REGISTRY}/foundation-python-sqlite:latest"]
}

target "libffi" {
  inherits = ["foundation-base"]
  args = {
    LIB_NAME = "libffi"
    LIB_URL = "https://github.com/libffi/libffi/archive/refs/tags/v3.5.2.tar.gz"
    LIB_SHA = "4aa7ecdbb7abc862f876cc0b0484f944fe6c49633071d36a964ad94f06d02ee08c76dceed5d6897da02c357515033f084a9a4da3a22bdd559316a5dca736332d"
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
  }
  tags = ["${REGISTRY}/foundation-python-consolidated:latest"]
}
