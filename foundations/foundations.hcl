variable "REGISTRY" {
  default = "ghcr.io/mbuccarello"
}

group "default" {
  targets = ["static", "base", "cc"]
}

target "builder" {
  dockerfile = "foundations/builder.Dockerfile"
  target = "builder"
  context = "."
  platforms = ["linux/amd64"]
}

target "static" {
  dockerfile = "foundations/static.Dockerfile"
  target = "static"
  context = "."
  contexts = { builder = "target:builder" }
  tags = ["${REGISTRY}/static:latest"]
}

target "base" {
  dockerfile = "foundations/base.Dockerfile"
  target = "base"
  context = "."
  contexts = { builder = "target:builder", static = "target:static" }
  tags = ["${REGISTRY}/base:latest"]
}

target "zlib" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "zlib-builder"
  context = "."
  platforms = ["linux/amd64"]
  args = {
    LIB_NAME = "zlib"
    LIB_URL = "https://github.com/madler/zlib/archive/refs/tags/v1.3.1.tar.gz"
    LIB_CONFIG = "--shared"
  }
  contexts = { builder = "target:builder" }
}

target "openssl" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "openssl-builder"
  context = "."
  platforms = ["linux/amd64"]
  args = {
    LIB_NAME = "openssl"
    LIB_URL = "https://github.com/openssl/openssl/releases/download/openssl-3.4.0/openssl-3.4.0.tar.gz"
    LIB_CONFIG = "shared zlib"
  }
  contexts = { builder = "target:builder" }
}

target "libxcrypt" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "libxcrypt-builder"
  context = "."
  platforms = ["linux/amd64"]
  args = {
    LIB_NAME = "libxcrypt"
    LIB_URL = "https://github.com/besser82/libxcrypt/releases/download/v4.4.36/libxcrypt-4.4.36.tar.xz"
    LIB_CONFIG = "--disable-werror"
  }
  contexts = { builder = "target:builder" }
}

target "cc" {
  dockerfile = "foundations/cc.Dockerfile"
  target = "cc"
  context = "."
  contexts = {
    builder = "target:builder"
    base = "target:base"
    zlib = "target:zlib"
    openssl = "target:openssl"
    libxcrypt = "target:libxcrypt"
  }
  tags = ["${REGISTRY}/cc:latest"]
}

