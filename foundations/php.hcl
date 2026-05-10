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
    RUNTIME_NAME = "php"
    RUNTIME_VER = "8.3"
    RUNTIME_URL = "DNF"
  }
  contexts = {
    cc = "docker-image://${REGISTRY}/cc:latest"
    builder = "target:foundations"
    zlib = "target:zlib"
    brotli = "target:brotli"
    openssl = "target:openssl"
    icu = "target:icu"
    ncurses = "target:ncurses"
    readline = "target:readline"
    libxml2 = "target:libxml2"
    sqlite = "target:sqlite"
    oniguruma = "target:oniguruma"
    krb5 = "target:krb5"
    curl = "target:curl"
    libxcrypt = "target:libxcrypt"
    bzip2 = "target:bzip2"
    pcre2 = "target:pcre2"
  }
  tags = ["${REGISTRY}/php-distroless:latest"]
}

target "runtime-debug" {
  inherits = ["runtime"]
  target = "runtime-debug"
  tags = ["${REGISTRY}/php-distroless:debug"]
}
