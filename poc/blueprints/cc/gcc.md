# GNU Compiler Collection (gcc)

## Overview
The GNU Compiler Collection provides the definitive standard C/C++ runtimes required by dynamically executed software. Specifically, it generates `libstdc++.so`, `libgcc_s.so`, and `libgomp.so`. 

## Why compile from source?
Almost every executable (JVM, Node) relies inherently on the C++ runtime to process arrays and allocate memory objects. By compiling GCC natively, we perfectly align these critical libraries structurally onto our custom `glibc` layer without extracting alien distribution layers.

## Build Configuration
To compile strictly the dynamic runtimes efficiently without recompiling the entire GCC toolkit recursively, Distroless-The-Hard-Way bypasses the bootstrap phase:
```bash
../configure --prefix=/usr --enable-languages=c,c++ --disable-multilib --disable-bootstrap
make
make install-target-libgcc install-target-libstdc++-v3 DESTDIR=/sovereignforge_out
```
