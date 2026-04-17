# Semgrep Static Analysis

## Purpose
In "Distroless The Hard Way", our fundamental security guarantee comes from evaluating source code *before* it is transformed into a compiled binary. We use **Semgrep** as our primary Static Application Security Classifier (SAST) tool. 

## How It's Used
Semgrep is integrated directly into stage 1 of our atomic foundation pipelines (e.g., `build-glibc`, `build-openssl`). Before `make` is even executed, Semgrep analyzes the raw C/C++ `.tar.gz` artifacts.

**Current Rulesets**
We are currently evaluating the strictness needed for our C/C++ upstream dependencies. Because these are critical OS foundations tested by thousands globally, we want to balance visibility with false positives. 

Semgrep currently defaults to checking standard security registers (`p/c` and `p/cpp`). We are tracking the formal implementation of `p/c/security` directly as a hard-failing check in the future.

## Why Semgrep?
The "XZ Utils" backdoor attack proved that binary-only distribution is a black box. A malicious actor can inject opaque compiled `.so` files into an ecosystem. By executing Semgrep *on the source* immediately before compiling it ourselves natively, we deny any pre-compiled obfuscation. 
