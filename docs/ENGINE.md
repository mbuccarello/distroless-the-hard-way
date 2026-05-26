# The Distroless Engine

The **Distroless Engine** (`engine/engine.py`) is the core build orchestration component of the Distroless The Hard Way project. Rather than relying on static, hardcoded Dockerfiles or shell scripts, the engine dynamically generates container configurations, compilation parameters, and Docker Bake (HCL) blueprints by analyzing upstream package definitions and package databases.

---

## 1. Engine Core Pipeline Architecture

The engine automates the entire packaging life cycle through a sequential, metadata-driven pipeline:

```text
+-------------------+      +-------------------+      +--------------------+
|  stacks/*.yaml    | ---> |  Arch PKGBUILD    | ---> |  Docker Bake HCL   |
|  Stack Definition |      |  Metadata Parser  |      |  foundations/*.hcl |
+-------------------+      +-------------------+      +--------------------+
                                    |
                                    v
                           +-------------------+
                           |  Dockerfile atom  |
                           |  cc-*.Dockerfile  |
                           +-------------------+
```

### 1.1 Step 1: Stack Definition Parsing
The engine reads declarative YAML files under `stacks/*.yaml` (e.g., `stacks/php.yaml`). These files define:
- Pinned runtime versions and official source tarball URLs.
- Dynamic dependency listings specifying foundational C/C++ libraries.
- Specialized `./configure` or compilation flags for the language runtime.

### 1.2 Step 2: Arch Linux Metadata Discovery
For every C/C++ dependency (e.g., openssl, sqlite, zlib, libxml2, curl) defined in the stack, the engine utilizes `engine/discovery.py` to query the official Arch Linux package repository:
- Fetches the raw upstream `PKGBUILD` file dynamically from the Arch Linux packaging GitLab.
- Parses the build script to extract the exact upstream source code URL and optimal `./configure` flags used by Arch Linux maintainers.
- Dynamically resolves transitive dependencies to construct a complete, validated build graph.

### 1.3 Step 3: OCI Atom Caching (`/artifacts`)
To prevent duplicate compilations and enforce modular build separation:
- The engine generates independent builder targets in `foundations/*.hcl` for each dependency (Atoms).
- Each Atom is compiled in an ephemeral environment. The build step targets a prefix directory (usually `/opt/distroless`).
- Upon successful execution of `make install`, the compiled headers, binaries, and shared libraries are written to an intermediate `/artifacts/usr/` path.
- These intermediate `/artifacts/` are stored as cached layers, allowing downstream layers to dynamically copy only the required files (Registry-First Orchestration).

### 1.4 Step 4: Dynamic Dynamic Linker Scanner (`ldd`)
During L4 runtime assembly:
- All source-built runtime files are written to `/runtime-root`.
- The engine embeds an automated post-build shell scanner that traverses all executables and shared libraries under `/runtime-root/usr/bin/` and `/runtime-root/usr/lib/`.
- Executes `ldd` on each binary to resolve dynamic shared objects transitively.
- Dynamically copies the resolved system-level libraries (e.g., `libcrypto.so`, `libssl.so`, `libffi.so`) from the CC layer to `/runtime-root/usr/lib64/` or `/runtime-root/usr/lib/`.
- Runs `ldconfig -r /runtime-root` to update the ununified dynamic linker cache.

---

## 2. Compiler Security Hardening & Linker Specifications

To enforce security and optimize performance, the engine dynamically injects specific compiler (`CFLAGS`, `CXXFLAGS`) and linker (`LDFLAGS`) parameters before building any Atom or runtime stack.

### 2.1 CFLAGS / CXXFLAGS Hardening Specifications

The engine exports the following flags globally for all source builds:
```bash
export CFLAGS="$CFLAGS -g0 -O1 -fstack-protector-strong -D_FORTIFY_SOURCE=2"
export CXXFLAGS="$CXXFLAGS -g0 -O1 -fstack-protector-strong -D_FORTIFY_SOURCE=2"
```

#### Engineering Rationale:
*   **`-fstack-protector-strong` (Stack Smashing Protection):**
    Instructs the compiler to insert defensive stack canary guards before local buffers. If a stack buffer overflow occurs (stack smashing), the canary value is overwritten, triggering an immediate execution halt (`SIGABRT`) before the hijacked return pointer can execute malicious payload shellcode.
*   **`-D_FORTIFY_SOURCE=2` (Buffer Bounds Checking):**
    Enforces compile-time and runtime check wrappers for standard glibc string and memory operations (e.g., `memcpy`, `strcpy`, `memset`). If a buffer overflow or integer mismatch is detected during runtime execution, the process is safely terminated.
*   **`-g0` (Size Optimization):**
    Discards all debugging symbols and DWARF sections from the compiled binaries. This dramatically minimizes the final binary size, reducing OCI layer footprint and making binary reverse-engineering more complex.
*   **`-O1` (Base Compiler Optimization):**
    Enables basic dead-code elimination and optimization passes. This compiler pass is strictly required for the dynamic checks in `-D_FORTIFY_SOURCE` to compile and execute effectively.

### 2.2 LDFLAGS Linkage Guard Specification

The engine exports the following linker parameters:
```bash
export LDFLAGS="-L/opt/distroless/lib -L/opt/distroless/lib64 -Wl,-rpath,/usr/lib"
```

#### Engineering Rationale:
*   **`-Wl,-rpath,/usr/lib` (Runpath Pinning):**
    Pins `/usr/lib` (which is symlinked to `/usr/lib64` on 64-bit systems) as the primary dynamic library search path (`DT_RUNPATH`) inside the ELF binary header. This guarantees that when the runtime binary is executed, the dynamic linker will load high-assurance, source-built dependencies from our cc foundation layer, completely ignoring and isolating host system library search paths or library search path poisoning (`LD_LIBRARY_PATH` injection).

---

## 3. Operational CLI Examples

### 3.1 Regenerating Foundations (L1 - L3)
To regenerate the base HCL specifications (`foundations/foundations.hcl`) and core Dockerfiles (`cc.Dockerfile`, `base.Dockerfile`):
```bash
python3 engine/engine.py --mode foundation
```

### 3.2 Regenerating Stackblueprints (L4)
To regenerate stack assembly manifests (e.g., `foundations/php.hcl`) and dynamic dynamic-linking configurations:
```bash
python3 engine/engine.py --mode runtime --stack stacks/php.yaml
```
