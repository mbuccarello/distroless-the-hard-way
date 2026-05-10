variable "REGISTRY" {
  default = "ghcr.io/mbuccarello"
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
  args = {
    LIB_NAME = "zlib"
    LIB_URL = "https://github.com/madler/zlib/archive/refs/tags/v1.3.1.tar.gz"
    LIB_CONFIG = "--shared"
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
  args = {
    LIB_NAME = "icu"
    LIB_URL = "https://github.com/unicode-org/icu/releases/download/release-75-1/icu4c-75_1-src.tgz"
    LIB_CONFIG = "--enable-static --enable-shared"
    LIB_SUBDIR = "source"
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
  args = {
    LIB_NAME = "brotli"
    LIB_URL = "https://github.com/google/brotli/archive/refs/tags/v1.1.0.tar.gz"
  }
  contexts = {
    builder = "target:foundations"
  }
}

target "c-ares" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "c-ares"
  context = "."
  platforms = ["linux/amd64"]
  args = {
    LIB_NAME = "c-ares"
    LIB_URL = "https://github.com/c-ares/c-ares/releases/download/v1.34.2/c-ares-1.34.2.tar.gz"
  }
  contexts = {
    builder = "target:foundations"
  }
}

target "nghttp2" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "nghttp2"
  context = "."
  platforms = ["linux/amd64"]
  args = {
    LIB_NAME = "nghttp2"
    LIB_URL = "https://github.com/nghttp2/nghttp2/releases/download/v1.64.0/nghttp2-1.64.0.tar.gz"
    LIB_CONFIG = "--enable-lib-only"
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
  args = {
    LIB_NAME = "libxcrypt"
    LIB_URL = "https://github.com/besser82/libxcrypt/releases/download/v4.4.36/libxcrypt-4.4.36.tar.xz"
    LIB_CONFIG = "--disable-werror --enable-hashes=all --enable-obsolete-api=no"
  }
  contexts = {
    builder = "target:foundations"
  }
}

target "cc-nodejs" {
  dockerfile = "foundations/cc-nodejs.Dockerfile"
  target = "cc"
  context = "."
  contexts = {
    builder = "target:foundations"
    base = "docker-image://${REGISTRY}/base:latest"
    zlib = "target:zlib"
    openssl = "target:openssl"
    icu = "target:icu"
    brotli = "target:brotli"
    c-ares = "target:c-ares"
    nghttp2 = "target:nghttp2"
    libxcrypt = "target:libxcrypt"
  }
}

target "runtime" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "runtime"
  context = "."
  args = {
    RUNTIME_NAME = "nodejs"
    RUNTIME_VER = "20"
    RUNTIME_URL = "https://nodejs.org/dist/v20.18.1/node-v20.18.1-linux-x64.tar.xz"
  }
  contexts = {
    cc = "target:cc-nodejs"
    builder = "target:foundations"
  }
  tags = ["${REGISTRY}/nodejs-distroless:latest"]
}

target "runtime-debug" {
  inherits = ["runtime"]
  target = "runtime-debug"
  tags = ["${REGISTRY}/nodejs-distroless:debug"]
}
