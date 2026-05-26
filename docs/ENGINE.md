# The Distroless Engine

The **Distroless Engine** (`engine/engine.py`) is the core build orchestration component of the Distroless The Hard Way project. Rather than relying on static, hardcoded Dockerfiles or shell scripts, the engine dynamically generates container configurations, compilation parameters, and Docker Bake (HCL) blueprints by analyzing upstream package definitions and package databases.

---

## 1. Engine Core Pipeline Architecture

The engine automates the entire packaging life cycle through a sequential, metadata-driven pipeline:

![Engine Core Pipeline Architecture](images/engine_orchestration.png)

### 1.1 Phase 1: Input Specifications
The orchestration begins by parsing two primary declarative configuration inputs:
*   **Stack Definitions (`stacks/*.yaml`)**: Define stack-specific runtime parameters, locked language versions, compile-time flags, and high-level, direct library dependencies (e.g., `zlib`, `openssl`, `libxcrypt`, `curl`).
*   **Central Matrix (`engine/config.yaml`)**: Decouples orchestrator logic from static values. It maps package names to upstream fallback tarball URLs, defines explicit dependency overrides, and houses the precise `./configure` flag catalogs and subdirectory targets for all foundational Atoms.

### 1.2 Phase 2: Dependency & Metadata Discovery
Using the input parameters, the engine traverses the dependency boundaries to construct a complete build timeline:
*   **Discovery Engine (`DiscoveryEngine` class in [engine/discovery.py](../engine/discovery.py))**: Queries the official Arch Linux package repository to fetch and parse raw `PKGBUILD` scripts. This dynamically extracts optimal maintainer configure parameters and maps potential transitive library dependencies.
*   **DAG Resolver (`DAGResolver` class in [engine/engine.py](../engine/engine.py))**: Translates the raw metadata into a **Directed Acyclic Graph (DAG)**. It recursively resolves transitive package chains, filters out standard glibc/system packages, and executes a **depth-first search (DFS) topological sort**. By tracking active recursion stacks, the resolver validates the graph against circular loops (cycle detection) and outputs a linearized sequence guaranteeing that every dependency is listed and compiled prior to the packages that depend on it.

### 1.3 Phase 3: Manifest & Target Generation
Once the topological build order is linearized:
*   **HCL Generator (`HCLGenerator` class in [engine/engine.py](../engine/engine.py))**: Evaluates the resolved dependency sequence and dynamically formats the compilation parameters:
    *   **Docker Bake HCL (`foundations/*.hcl`)**: Generates targeted Bake blueprints mapping core compiler contexts, Atom cache boundaries, and layer inheritance for each package.
    *   **Dockerfile Templates (`foundations/*.Dockerfile`)**: Dynamically compiles the CC base layer (`cc-*.Dockerfile`) and L4 final assembly templates (`runtime.Dockerfile`) to specify exact stage parameters.

### 1.4 Phase 4: Cache & ABI Compliance Assembly
During image compilation, the generated manifests execute in an isolated assembly pipeline:
*   **OCI Atom Builder Stage (`/artifacts/usr`)**: Compiles each Atom in an ephemeral container using the global security-hardened compiler flags. Successful compilation writes binary objects and dynamic headers directly to a modular `/artifacts/usr` layer cache.
*   **Runtime Setup Stage (`/runtime-root`)**: Copy-extracts all pre-compiled Atoms and language source archives into a unified, isolated `/runtime-root` directory structure.
*   **dynamic Linker Scan (`ldd` & `ldconfig`)**: Executes a dynamic post-build scanner that traverses all `/runtime-root` executables. It runs `ldd` on each dynamic file, transitively copies all required dynamic libraries (e.g., `libssl.so`) from the CC base layer, and runs `ldconfig -r /runtime-root` to generate a secure, unified dynamic linker lookup table.

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

## 3. Central Matrix Configuration Schema (config.yaml)

To achieve a clean separation of concerns, all static package details, source fallback archives, custom compilation parameters, and dependency overrides are decoupled from the Python code and defined in the central configuration matrix: `engine/config.yaml`.

The schema defines three main sections:
*   **`sources`**: Maps package names to their official upstream source archive URLs. These are used as deterministic fallbacks if the dynamic Arch Linux metadata discovery fails or is disabled.
*   **`dependencies`**: Declares package dependency overrides that are injected into the DAGResolver graph. This ensures that transitive dependencies that are dynamically compiled (e.g., linking `openssl` for the `curl` library) are correctly loaded into the build process even if they are not explicitly declared in standard Arch Linux packages.
*   **`packages`**: Defines custom compilation options and layout overrides for specific packages:
    *   `config`: Custom compiler flags passed directly to `./configure`, `./Configure`, or `cmake`.
    *   `subdir`: Declares the subdirectory in the extracted source archive where the build script is located (e.g., `source` for ICU or `src` for Kerberos v5).

### 3.1 Script Consumption Pattern
During the initialization of `MetadataManager`, `engine/engine.py` dynamically loads this YAML configuration relative to the script's directory:
```python
script_dir = os.path.dirname(os.path.abspath(__file__))
config_path = os.path.join(script_dir, "config.yaml")
with open(config_path, "r") as f:
    config = yaml.safe_load(f)
```
These attributes (`self.hardcoded_sources`, `self.dependency_overrides`, and `self.package_metadata`) are used directly during graph resolution and HCL generator phases.

---

## 4. Package Configure Hardening Catalog

To minimize build footprint, optimize dynamic linking, and maintain a highly secure container posture, each source-compiled Atom uses custom configure flags. The table below documents the exact systems-engineering rationales behind the compiler parameters declared in `engine/config.yaml`:

| Package | Compile-Time Configuration Parameter | Technical & Security Engineering Rationale |
| :--- | :--- | :--- |
| **zlib** | `--shared` | Compiles as a shared object library (`.so`), which is strictly required for downstream dynamic linkage by other Atoms and language runtimes. |
| **openssl** | `shared zlib` | `shared`: Generates shared library objects instead of static archives. <br>`zlib`: Links against our zlib Atom dynamically to enable native gzip/deflate compression within TLS connections. |
| **ncurses** | `--with-shared --enable-widec --enable-pc-files --with-termlib` | `--with-shared`: Generates shared library files. <br>`--enable-widec`: Compiles with UTF-8 wide-character support for Unicode terminal screen rendering. <br>`--enable-pc-files`: Outputs pkg-config definitions for discovery by downstream library builds. <br>`--with-termlib`: Splits low-level terminal capability checks into a dedicated termlib library. |
| **readline** | `--with-curses` | Links readline command line history and input rendering dynamically against our ncurses Atom. |
| **libxcrypt** | `--disable-werror --enable-hashes=all --enable-obsolete-api=no` | `--disable-werror`: Prevents compilation warnings from halting builder execution. <br>`--enable-hashes=all`: Enables modern secure hashing algorithms (bcrypt, sha512, yescrypt). <br>`--enable-obsolete-api=no`: Disables ancient and insecure legacy crypt interfaces, reducing the attack surface. |
| **icu** | `--enable-static --enable-shared --disable-tests --disable-samples --disable-extras --disable-icuio --disable-layoutex --disable-tools` | `--enable-static --enable-shared`: Compiles both library forms. <br>`--disable-tests --disable-samples --disable-extras --disable-icuio --disable-layoutex --disable-tools`: Disables non-essential tools, helper APIs, and sample code, severely reducing the final container image layer footprint. |
| **nghttp2** | `--enable-lib-only` | Compiles only the C library shared objects, excluding CLI tool binaries to maintain a zero-executable distroless footprint. |
| **krb5** | `--with-crypto-impl=openssl --with-system-verto=no --disable-rpath` | `--with-crypto-impl=openssl`: Outsources cryptographic and TLS needs to our high-assurance openssl Atom. <br>`--with-system-verto=no`: Disables vertical execution loop layers. <br>`--disable-rpath`: Prevents the binary from embedding hardcoded path parameters from the builder's environment. |
| **libxml2** | `--without-python --without-icu` | `--without-python`: Excludes Python bindings and helper modules inside the OCI Atom layer. <br>`--without-icu`: Disables massive Unicode lookup tables, optimizing size and linkage times. |
| **curl** | `--with-openssl=/opt/distroless --with-zlib=/opt/distroless --with-nghttp2=/opt/distroless --with-ca-bundle=/etc/ssl/certs/ca-certificates.crt --without-libpsl` | `--with-openssl/zlib/nghttp2=/opt/distroless`: Configures curl to dynamically link against our custom built Atoms compiled in `/opt/distroless`. <br>`--with-ca-bundle=/etc/ssl/certs/ca-certificates.crt`: Pins the standard CA certificate path. <br>`--without-libpsl`: Bypasses the Public Suffix List check to avoid build-time dynamic resolution failures. |
| **pcre2** | `--enable-jit --enable-unicode` | `--enable-jit`: Enables JIT compilation for PCRE regex matching, speeding up PHP/Python execution. <br>`--enable-unicode`: Compiles with full Unicode/UTF-8 regex standard checks. |
| **oniguruma** | `--enable-shared` | Compiles as a shared object library (`.so`) needed by PHP multibyte string (`mbstring`) processing modules. |

---

## 5. Operational CLI Examples

### 5.1 Regenerating Foundations (L1 - L3)
To regenerate the base HCL specifications (`foundations/foundations.hcl`) and core Dockerfiles (`cc.Dockerfile`, `base.Dockerfile`):
```bash
python3 engine/engine.py --mode foundation
```

### 5.2 Regenerating Stack Blueprints (L4)
To regenerate stack assembly manifests (e.g., `foundations/php.hcl`) and dynamic dynamic-linking configurations:
```bash
python3 engine/engine.py --mode runtime --stack stacks/php.yaml
```

---

## 6. Build Engine CLI Parameter Reference

The Build Engine (`engine/engine.py`) exposes the following command-line interface arguments for orchestrating the build matrix:

| Argument | Type | Required | Default | Technical Specification & Behavior |
| :--- | :--- | :--- | :--- | :--- |
| `--mode` | `string` | **Yes** | `None` | Restricts the execution scope. Accepted values:<br>- `foundation`: Resolves core CC layer dependencies (`zlib`, `openssl`, `libxcrypt`) and outputs foundational targets.<br>- `runtime`: Compiles stack-specific blueprints and dynamic dependencies. |
| `--stack` | `filepath` | Only for `runtime` | `None` | Path to the target stack definition YAML file (e.g., `stacks/php.yaml`). Contains the stack name, runtime configuration, and required dependencies. |
| `--force-build`| `flag` | No | `False` | Overrides the registry-caching check. When set, forces the engine to mark all Atom dependencies as missing locally, forcing a full source compilation cycle in the Docker Bake HCL output. |
