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
    RUNTIME_NAME = "perl"
    RUNTIME_VER = "5.38"
    RUNTIME_URL = "DNF"
  }
  contexts = {
    cc = "docker-image://${REGISTRY}/cc:latest"
    builder = "target:foundations"
    zlib = "target:zlib"
    gdbm = "target:gdbm"
    bzip2 = "target:bzip2"
    brotli = "target:brotli"
    openssl = "target:openssl"
    libxcrypt = "target:libxcrypt"
  }
  tags = ["${REGISTRY}/perl-distroless:latest"]
}

target "runtime-debug" {
  inherits = ["runtime"]
  target = "runtime-debug"
  tags = ["${REGISTRY}/perl-distroless:debug"]
}
