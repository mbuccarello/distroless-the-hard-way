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

target "krb5" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "krb5"
  context = "."
  platforms = ["linux/amd64"]
  args = {
    LIB_NAME = "krb5"
    LIB_URL = "https://web.mit.edu/kerberos/dist/krb5/1.21/krb5-1.21.3.tar.gz"
    LIB_CONFIG = "--with-crypto-impl=openssl"
    LIB_SUBDIR = "src"
  }
  contexts = {
    builder = "target:foundations"
    openssl = "target:openssl"
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

target "cc-dotnet" {
  dockerfile = "foundations/cc.Dockerfile"
  target = "cc"
  context = "."
  contexts = {
    builder = "target:foundations"
    base = "docker-image://${REGISTRY}/base:latest"
    zlib = "target:zlib"
    openssl = "target:openssl"
    icu = "target:icu"
    krb5 = "target:krb5"
    libxcrypt = "target:libxcrypt"
    brotli = "target:brotli"
  }
}

target "runtime" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "runtime"
  context = "."
  args = {
    RUNTIME_NAME = "dotnet"
    RUNTIME_VER = "8.0"
    RUNTIME_URL = "https://builds.dotnet.microsoft.com/dotnet/Runtime/8.0.26/dotnet-runtime-8.0.26-linux-x64.tar.gz"
  }
  contexts = {
    cc = "target:cc-dotnet"
    builder = "target:foundations"
  }
  tags = ["${REGISTRY}/dotnet-distroless:latest"]
}

target "runtime-debug" {
  inherits = ["runtime"]
  target = "runtime-debug"
  tags = ["${REGISTRY}/dotnet-distroless:debug"]
}
