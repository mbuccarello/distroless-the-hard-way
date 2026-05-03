[<- Back to Main README](../README.md)

# Pipeline Orchestration: The Unified Distroless Bake Engine

Distroless The Hard Way uses a data-driven, unified orchestration model powered by the **Distroless Engine** and **Docker Bake**. This replaces the fragmented GitHub Action workflows with a single, high-assurance build process.

## ⚙️ The Orchestration Engine
All builds are driven by `distroless_engine.py`, which performs:
1.  **Dependency Resolution**: Maps the stack's dependency tree using Arch Linux PKGBUILD intelligence.
2.  **Metadata Extraction**: Gathers optimized `./configure` flags and source URLs.
3.  **HCL Generation**: Creates a dynamic `docker-bake.hcl` capturing the full build graph.
4.  **DAG Visualization**: Automatically generates premium Mermaid diagrams for auditability.

---

## 🏗️ The 4-Tier Hierarchy
The pipeline follows a strictly linear cascading model:

1.  **Layer 1 (Static)**: The minimal root (certs, users, tzdata, netbase).
2.  **Layer 2 (Base)**: Dynamic linker (glibc) and NSS networking libraries.
3.  **Layer 3 (CC)**: ABI-stabilized foundation (GCC runtime + source-built core libraries).
4.  **Layer 4 (Runtime)**: Language-specific environments (Python, Node.js, Java, .NET, PHP, Perl).

---

## 🚀 GitHub Actions Integration

The project has transitioned to a **Unified Master Pipeline**:

*   **Workflow**: `distroless-bake-master.yml`
*   **Capability**: Can build any stack defined in `stacks/*.yaml` using a single entrypoint.
*   **Fleet Updates**: `distroless-fleet-build.yml` orchestrates weekly security updates for the entire catalog in parallel.

---

## 🛡️ Sovereign Security Gates
Every image produced by the Bake Engine must pass through the following high-assurance gates:

1.  **SLSA Level 3**: Non-falsifiable build provenance for every layer.
2.  **Cosign Signing**: Keyless OIDC-based signatures.
3.  **Trivy SBOM**: Automated generation and attachment of SPDX manifests.
4.  **License Extraction**: Automatic harvest of license files to ensure open-source compliance.

---

## 🛠️ Local Execution
To replicate the CI/CD environment locally:
```bash
./distroless_engine.py --stack stacks/python.yaml --graph
docker buildx bake runtime
```
