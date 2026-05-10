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
