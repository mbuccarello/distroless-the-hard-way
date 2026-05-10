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
    RUNTIME_NAME = "dotnet"
    RUNTIME_VER = "8.0"
    RUNTIME_URL = "https://builds.dotnet.microsoft.com/dotnet/Runtime/8.0.26/dotnet-runtime-8.0.26-linux-x64.tar.gz"
  }
  contexts = {
    cc = "docker-image://${REGISTRY}/cc:latest"
    builder = "target:foundations"
    zlib = "target:zlib"
    brotli = "target:brotli"
    openssl = "target:openssl"
    icu = "target:icu"
    krb5 = "target:krb5"
    libxcrypt = "target:libxcrypt"
  }
  tags = ["${REGISTRY}/dotnet-distroless:latest"]
}

target "runtime-debug" {
  inherits = ["runtime"]
  target = "runtime-debug"
  tags = ["${REGISTRY}/dotnet-distroless:debug"]
}
