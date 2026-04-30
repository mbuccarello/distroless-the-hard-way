group "default" {
  targets = [, "consolidated"]
}

variable "REGISTRY" { default = "ghcr.io/mbuccarello" }

target "foundation-base" {
  dockerfile = "Dockerfile"
  context = "."
}

target "consolidated" {
  dockerfile = "Dockerfile.consolidated"
  context = "."
  contexts = {
  }
  tags = ["${REGISTRY}/foundation-python-consolidated:latest"]
}
