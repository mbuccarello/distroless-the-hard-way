# Local Debugging & Iteration

With the move to the **Unified Distroless Engine**, local debugging is now standardized across all language stacks. You no longer need manual debug Dockerfiles; the engine generates them for you.

## ⚙️ Debugging with the Engine

To iterate on a specific runtime (e.g., Python) locally:

### 1. Generate the Debug Build Context
Run the engine for the target stack:
```bash
./distroless_engine.py --stack stacks/python.yaml --graph
```
This generates the `docker-bake.hcl` and `Dockerfile.cc` tailored for that stack.

### 2. Build the Debug Target
Use Docker Bake to build the `:debug` variant, which includes **Busybox** for shell access:
```bash
docker buildx bake runtime-debug
```

### 3. Interactive Troubleshooting
Run the generated debug image with an interactive shell:
```bash
docker run --rm -it --entrypoint /usr/bin/sh ghcr.io/mbuccarello/python-distroless:debug
```

From here, you can:
*   Inspect library linkage: `ldd /usr/bin/python3`
*   Check filesystem layout: `ls -R /usr/lib`
*   Verify certificate trust: `curl -v https://google.com`

---

## 🛠️ Modifying Build Logic
If you need to test a different `./configure` flag or add a new dependency:
1.  **Edit the Stack YAML**: Modify `stacks/<stack>.yaml`.
2.  **Re-run the Engine**: The engine will re-resolve the DAG and update the Bake HCL.
3.  **Re-build**: Run `docker buildx bake runtime-debug` again.

## 📂 Deprecated Environments
The legacy manual debug environments (which relied on Fedora extraction) have been moved to `debug/deprecated/`. These are no longer ABI-compatible with the current unified hierarchy.
