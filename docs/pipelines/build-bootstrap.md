> [!NOTE]
> **The Hard Way:** This is an educational tutorial pipeline. Every single step here performs compilation from raw source. We do not use Debian extraction.

# Pipeline: Bootstrap Extractor (Stage 0)

## Overview
When constructing a completely isolated environment (from `scratch`), there are no tools available to move, compress, or extract incoming layers. Traditional methods cheat by temporarily using an `alpine` or `ubuntu` base to extract `.tar.gz` files into a directory, then moving that directory into the final image.

In Distroless The Hard Way, we consider this a violation of zero-trust, as it opens the operation to potential host-based compromises or tainted extraction binaries.

Instead, **Stage 0** compiles a pure, verified version of `tar` and `gzip` natively from `busybox` source code, pushing it to a specialized `bootstrap` OCI image to be used exclusively during assembly phases.

## Execution Flow

1. **Source Retrieval**: 
   The pipeline downloads the pristine `busybox` `.tar.bz2` archive directly from official upstream servers.

2. **Static Compilation**:
   We configure `busybox` to compile statically (`make defconfig` + `CONFIG_STATIC=y`). This ensures that the resulting `tar` executable has exactly zero dynamically linked dependencies (it does not even require `glibc`).

3. **Artifact Isolation**:
   We isolate the exact capabilities we need by pushing only the compiled `tar` and `gzip` binaries into an empty `scratch` image.

4. **Publication & Attestation**:
   The `bootstrap` image is pushed to the GitHub Container Registry (`ghcr.io`) and cryptographically signed using Cosign (Keyless).

## Usage in Assembly
The generated `bootstrap` image is strictly used as an ephemeral layer during Stage 2 Assembly:
```dockerfile
# Pull our zero-trust extractor
COPY --from=bootstrap /tar /tar
COPY --from=ghcr.io/org/artifacts-glibc:latest /glibc-layer.tar.gz /

# Execute securely natively
RUN ["/tar", "-xzf", "/glibc-layer.tar.gz"]
```
