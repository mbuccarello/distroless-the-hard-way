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
    RUNTIME_NAME = "nodejs"
    RUNTIME_VER = "20"
    RUNTIME_URL = "https://nodejs.org/dist/v20.18.1/node-v20.18.1-linux-x64.tar.xz"
  }
  contexts = {
    cc = "docker-image://${REGISTRY}/cc:latest"
    builder = "target:foundations"
    zlib = "target:zlib"
    brotli = "target:brotli"
    openssl = "target:openssl"
    icu = "target:icu"
    c-ares = "target:c-ares"
    nghttp2 = "target:nghttp2"
    libxcrypt = "target:libxcrypt"
  }
  tags = ["${REGISTRY}/nodejs-distroless:latest"]
}

target "runtime-debug" {
  inherits = ["runtime"]
  target = "runtime-debug"
  tags = ["${REGISTRY}/nodejs-distroless:debug"]
}
