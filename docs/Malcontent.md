# Malcontent Capability Analysis

## What is Malcontent?
[Malcontent](https://github.com/chainguard-dev/malcontent) is an open-source tool built by Chainguard designed specifically for analyzing container images, binaries, and supply-chain artifacts for hidden malware, supply-chain attacks, and unexpected capabilities.

## Why is it Important?
While we use **Semgrep** on the source code before compilation, we must also verify the resulting output *after* compilation. 

Malcontent acts as our final guardian. It inspects the completed `base` and `cc` images to ensure the compilers did not statically link unexpected network sockets, obfuscated payloads, or capabilities that should not exist in a "distroless" environment. 

For instance, if a compromised `glibc` source subtly embedded a backdoor that reached out to the internet, Malcontent flags the binary as possessing unexpected networking capabilities.

## CI Integration
We run `malcontent analyze <image>` at the end of every `assemble` workflow. A failure in Malcontent hard-stops the pipeline, preventing compromised images from being signed or published.
