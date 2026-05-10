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

target "libpng" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "libpng"
  context = "."
  platforms = ["linux/amd64"]
  tags = ["${ATOMS_REGISTRY}/libpng:1.6.58"]
  args = {
    LIB_NAME = "libpng"
    LIB_URL = "SKIP"
  }
  contexts = {
    builder = "target:foundations"
    zlib = "target:zlib"
  }
}

target "freetype2" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "freetype2"
  context = "."
  platforms = ["linux/amd64"]
  tags = ["${ATOMS_REGISTRY}/freetype2:2.14.3"]
  args = {
    LIB_NAME = "freetype2"
    LIB_URL = "SKIP"
  }
  contexts = {
    builder = "target:foundations"
    brotli = "target:brotli"
    bzip2 = "target:bzip2"
    libpng = "target:libpng"
    zlib = "target:zlib"
  }
}

target "libjpeg-turbo" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "libjpeg-turbo"
  context = "."
  platforms = ["linux/amd64"]
  tags = ["${ATOMS_REGISTRY}/libjpeg-turbo:3.1.4.1"]
  args = {
    LIB_NAME = "libjpeg-turbo"
    LIB_URL = "SKIP"
  }
  contexts = {
    builder = "target:foundations"
  }
}

target "lcms2" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "lcms2"
  context = "."
  platforms = ["linux/amd64"]
  tags = ["${ATOMS_REGISTRY}/lcms2:2.19.1"]
  args = {
    LIB_NAME = "lcms2"
    LIB_URL = "https://github.com/mm2/Little-CMS/releases/download/lcms2.19.1/lcms2-2.19.1.tar.gz"
  }
  contexts = {
    builder = "target:foundations"
    libjpeg-turbo = "target:libjpeg-turbo"
  }
}

target "libx11" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "libx11"
  context = "."
  platforms = ["linux/amd64"]
  tags = ["${ATOMS_REGISTRY}/libx11:1.8.13"]
  args = {
    LIB_NAME = "libx11"
    LIB_URL = "SKIP"
  }
  contexts = {
    builder = "target:foundations"
  }
}

target "libxext" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "libxext"
  context = "."
  platforms = ["linux/amd64"]
  tags = ["${ATOMS_REGISTRY}/libxext:1.3.7"]
  args = {
    LIB_NAME = "libxext"
    LIB_URL = "SKIP"
  }
  contexts = {
    builder = "target:foundations"
    libx11 = "target:libx11"
  }
}

target "libxrender" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "libxrender"
  context = "."
  platforms = ["linux/amd64"]
  tags = ["${ATOMS_REGISTRY}/libxrender:0.9.12"]
  args = {
    LIB_NAME = "libxrender"
    LIB_URL = "SKIP"
  }
  contexts = {
    builder = "target:foundations"
    libx11 = "target:libx11"
  }
}

target "libxtst" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "libxtst"
  context = "."
  platforms = ["linux/amd64"]
  tags = ["${ATOMS_REGISTRY}/libxtst:1.2.5"]
  args = {
    LIB_NAME = "libxtst"
    LIB_URL = "SKIP"
  }
  contexts = {
    builder = "target:foundations"
    libxext = "target:libxext"
    libx11 = "target:libx11"
  }
}

target "alsa-lib" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "alsa-lib"
  context = "."
  platforms = ["linux/amd64"]
  tags = ["${ATOMS_REGISTRY}/alsa-lib:1.2.15.3"]
  args = {
    LIB_NAME = "alsa-lib"
    LIB_URL = "SKIP"
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

target "cc-java" {
  dockerfile = "foundations/cc-java.Dockerfile"
  target = "cc"
  context = "."
  contexts = {
    builder = "target:foundations"
    base = "docker-image://${REGISTRY}/base:latest"
    zlib = "target:zlib"
    brotli = "target:brotli"
    bzip2 = "target:bzip2"
    libpng = "target:libpng"
    freetype2 = "target:freetype2"
    libjpeg-turbo = "target:libjpeg-turbo"
    lcms2 = "target:lcms2"
    libx11 = "target:libx11"
    libxext = "target:libxext"
    libxrender = "target:libxrender"
    libxtst = "target:libxtst"
    alsa-lib = "target:alsa-lib"
    openssl = "target:openssl"
    libxcrypt = "target:libxcrypt"
  }
}

target "runtime" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "runtime"
  context = "."
  args = {
    RUNTIME_NAME = "java"
    RUNTIME_VER = "21.0.6"
    RUNTIME_URL = "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.6%2B7/OpenJDK21U-jdk_x64_linux_hotspot_21.0.6_7.tar.gz"
  }
  contexts = {
    cc = "target:cc-java"
    builder = "target:foundations"
    zlib = "target:zlib"
    brotli = "target:brotli"
    bzip2 = "target:bzip2"
    libpng = "target:libpng"
    freetype2 = "target:freetype2"
    libjpeg-turbo = "target:libjpeg-turbo"
    lcms2 = "target:lcms2"
    libx11 = "target:libx11"
    libxext = "target:libxext"
    libxrender = "target:libxrender"
    libxtst = "target:libxtst"
    alsa-lib = "target:alsa-lib"
    openssl = "target:openssl"
    libxcrypt = "target:libxcrypt"
  }
  tags = ["${REGISTRY}/java-distroless:latest"]
}

target "runtime-debug" {
  inherits = ["runtime"]
  target = "runtime-debug"
  tags = ["${REGISTRY}/java-distroless:debug"]
}
