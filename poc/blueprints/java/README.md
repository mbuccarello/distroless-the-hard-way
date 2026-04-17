# Java Execution Blueprint

The `java` application image forms the top of the dependency cascade (`Depends On: sovereign-distroless/cc`). 

Unlike the foundational OS components (`base` and `cc`) which must be mathematically compiled natively to cryptographically isolate the C-Libraries from foreign operating systems, the JVM is a high-level application binary.

## Application Binaries (Pre-Compiled)
Because the JVM interacts exclusively with the `glibc` API we have already secured, compiling the OpenJDK engine from raw C-code is excessively slow and provides minimal extra security guarantees.

Instead, Opensource-Distroless securely ingests verified pre-compiled runtimes and statically isolates them onto perfectly safe foundation bases.

*   [**`openjdk` (Adoptium Eclipse Temurin)**](openjdk.md): The official community OpenJDK 64-bit Server VM binary implementation.
