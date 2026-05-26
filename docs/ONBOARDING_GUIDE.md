# Onboarding Guide: Distroless The Hard Way

Welcome to **Distroless The Hard Way**! This guide will help you get started with the project, build your first distroless images locally, and understand the core layout of the repository.

---

## 1. Prerequisites

Before you start, ensure you have the following installed on your local machine:
- **Docker** with **Buildx** enabled (for bake builds).
- **Python 3.10+** (for the Distroless Engine).
- **Git** (to clone the repository).

---

## 2. Repository Layout

When you clone the repository, you'll find the following key directories:

- `/engine`: Contains `engine.py`, our custom orchestration tool that reads Arch Linux definitions and generates Docker configurations.
- `/foundations`: Contains the base Dockerfiles (`static`, `base`, `cc`, `builder`) and the generated HCL files for the foundational layers.
- `/stacks`: Contains YAML configuration files (e.g., `php.yaml`, `python.yaml`) for assembling specific language runtimes.
- `/docs`: Contains technical specifications, pipeline documentation, and architecture diagrams.

---

## 3. Quick Start: Local Build

To understand how the project works, let's build the **Python** distroless image stack from scratch locally.

### Step 1: Generate Foundation Manifests
First, generate the foundational configurations (which compile `glibc`, `openssl`, etc.):
```bash
python3 engine/engine.py --mode foundation
```

### Step 2: Build the CC Layer
Next, use Docker Buildx Bake to build the foundations up to the `cc` layer:
```bash
docker buildx bake --load -f foundations/foundations.hcl cc
```
*Note: This might take a few minutes as it downloads and compiles C libraries from source.*

### Step 3: Generate Runtime Manifests
Now, generate the build blueprints for the specific language stack (e.g., Python):
```bash
python3 engine/engine.py --mode runtime --stack stacks/python.yaml
```

### Step 4: Build the Final Runtime Image
Finally, build the Python distroless image:
```bash
docker buildx bake --load -f foundations/python.hcl python
```

You now have a fully operational, zero-trust, source-compiled Distroless Python image!

---

## 4. Onboarding a New Library or Atom

The Distroless Orchestrator is driven by a central configuration file at `engine/config.yaml`. To introduce a new C library or dependency atom into the build engine, follow these structured steps:

### Step 1: Declare the Upstream Source URL
Add the official upstream source tarball URL to the `sources` mapping in `engine/config.yaml`. This ensures a deterministic fallback if the dynamic Arch Linux PKGBUILD scraper fails or is bypassed:
```yaml
sources:
  my_new_lib: "https://example.com/releases/my_new_lib-1.0.0.tar.gz"
```

### Step 2: Define Compile-Time Configuration
Under the `packages` section, add your library and declare the precise configuration flags required by its `./configure`, `CMake`, or build system. You must include comments explaining the systems-engineering rationale for each flag:
```yaml
packages:
  # my_new_lib: Description of the library's role.
  # --shared: Compiles as a shared object library (.so) for dynamic linkage.
  # --disable-static: Excludes static archives to minimize Atom size.
  my_new_lib:
    config: "--shared --disable-static"
    # Optional: subdir: "src" (if the configure script is inside a subdirectory)
```

### Step 3: Map Stack Dependencies
If the library is required by a language stack, add it under the `dependencies` list in the stack's YAML config (e.g., `stacks/php.yaml` or `stacks/python.yaml`):
```yaml
dependencies:
  - name: my_new_lib
```

### Step 4: Map Dependency Overrides (Optional)
If your library requires custom dynamic linking overrides (e.g., forcing a dependency that is not declared in the upstream Arch Linux package repository), specify it in the `dependencies` mapping inside `engine/config.yaml`:
```yaml
dependencies:
  my_new_lib:
    - openssl
```

Once configured, re-run the build engine in foundation or runtime mode to dynamically generate the updated HCL and Dockerfile manifests.

---

## 5. Where to Go Next

- **[Architecture Specification](ARCHITECTURE.md)**: Deep dive into the 4-layer model and our FHS Unification strategy.
- **[Engine Documentation](ENGINE.md)**: Learn how the `engine.py` script orchestrates dependency graphs.
- **[Pipelines Documentation](PIPELINES.md)**: Understand our Tiered Pipeline Hierarchy in GitHub Actions.
