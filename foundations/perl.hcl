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

target "gdbm" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "gdbm"
  context = "."
  platforms = ["linux/amd64"]
  tags = ["${ATOMS_REGISTRY}/gdbm:1.26"]
  args = {
    LIB_NAME = "gdbm"
    LIB_URL = "https://ftp.gnu.org/pub/gnu/gdbm/gdbm-1.24.tar.gz"
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

target "cc-perl" {
  dockerfile = "foundations/cc-perl.Dockerfile"
  target = "cc"
  context = "."
  contexts = {
    builder = "target:foundations"
    base = "docker-image://${REGISTRY}/base:latest"
    zlib = "target:zlib"
    gdbm = "target:gdbm"
    bzip2 = "target:bzip2"
    libxcrypt = "target:libxcrypt"
    brotli = "target:brotli"
    openssl = "target:openssl"
  }
}

target "runtime" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "runtime"
  context = "."
  args = {
    RUNTIME_NAME = "perl"
    RUNTIME_VER = "5.38"
  }
  contexts = {
    cc = "target:cc-perl"
    builder = "target:foundations"
    zlib = "target:zlib"
    gdbm = "target:gdbm"
    bzip2 = "target:bzip2"
    libxcrypt = "target:libxcrypt"
    brotli = "target:brotli"
    openssl = "target:openssl"
  }
  tags = ["${REGISTRY}/perl-distroless:latest"]
}

target "runtime-debug" {
  inherits = ["runtime"]
  target = "runtime-debug"
  tags = ["${REGISTRY}/perl-distroless:debug"]
}
