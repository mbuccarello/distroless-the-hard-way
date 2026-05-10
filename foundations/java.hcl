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

target "runtime" {
  dockerfile = "foundations/runtime.Dockerfile"
  target = "runtime"
  context = "."
  args = {
    RUNTIME_NAME = "java"
    RUNTIME_VER = "21.0.11"
    RUNTIME_URL = "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.6%2B7/OpenJDK21U-jdk_x64_linux_hotspot_21.0.6_7.tar.gz"
  }
  contexts = {
    cc = "docker-image://${REGISTRY}/cc:latest"
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
