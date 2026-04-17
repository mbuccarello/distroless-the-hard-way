# C++ Runtime Blueprint (CC)

The `cc` blueprint is the second tier in the Opensource-Distroless cascade. It layers precisely on top of the `sovereign-distroless/base` foundational OS.

This layer exists because modern execution environments (like the JVM, Node V8, or Python) are written heavily in C++, requiring dynamic GNU C++ libraries to allocate memory and spawn threads.

## Foundational Components Compiled from Source

*   [**`gcc` (The GNU Compiler Collection)**](gcc.md): Natively orchestrating the GNU compiler source code specifically to parse and extract the `libstdc++` and `libgcc_s` generic runtimes safely on top of our isolated `glibc` base.
