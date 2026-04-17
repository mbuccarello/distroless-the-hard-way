# Archived Prototype: V1 Python Orchestrator

**⚠️ WARNING: This directory contains the deprecated V1 prototype.**

This `poc/` directory is an isolated archive of the original Python-based orchestrator used to test the earliest concepts of "Distroless The Hard Way" (formerly Sovereign Distroless). 

**It is NOT connected to the current V2 Architecture.**
For the live, production-grade GitHub Actions compilation architecture, please return to the repository root and consult `README.md` and the `docs/` directory.

---

## 🚀 Usage Guide (Archived)

The repository previously contained a Python-based orchestrator (`build.py`) which coordinated ephemeral Docker containers acting strictly as compiler sandboxes. It remains here strictly for historical reference.

```bash
# Compile the fundamental C-Library (glibc, openssl, zlib)
./build.py blueprints/base/base.yaml

# Compile the GNU C++ Runtime (libstdc++, libgcc_s)
./build.py blueprints/cc/cc.yaml

# Compile OpenJDK Java Native
./build.py blueprints/java/java.yaml
```

*Do not use these blueprints in production.*
