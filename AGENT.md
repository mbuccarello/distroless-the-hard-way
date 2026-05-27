# Distroless The Hard Way - AI Agent Guardrails (`AGENT.md`)

This file defines the core operating principles, architecture context, and strict guardrails for the `distroless-the-hard-way` repository. 

Whenever you (an AI agent) interact with this repository, you must read and **strictly adhere** to the following architectural rules. Failure to do so violates the primary mandate of the project.

## 1. Project Mission
The goal is an educational curriculum titled **Distroless The Hard Way**. 
It teaches users how to create distroless container images *without* relying on third-party OS ecosystems (such as extracting pre-compiled Ubuntu or Debian packages) to ensure absolute data transparency and zero-trust supply chain isolation. The tone must always remain highly technical, human, and educational ("The Hard Way" philosophy).

## 2. Core Operational Pillars
- **The Distroless Engine:** All image assembly and dependency orchestration must be handled by the specialized **Distroless Engine** (`engine/engine.py`). It operates in targeted modes (foundation/runtime).
- **Data-Driven Stacks:** New language runtimes must be defined as modular YAML files in `stacks/*.yaml`.
- **Targeted Assembly (Melange/Apko Style):** The architecture strictly enforces a modular 3-tier foundation hierarchy (`static -> base -> cc`) followed by a specialized runtime assembly. Each stage is atomic and versioned.
- **Zero OS Extraction:** You are strictly forbidden from writing workflows that rely on precompiled `.so` library binaries from host OS packages (e.g. `apt`, `apk`).
- **Rule: The Arch Linux Dependency Graph Protocol:** Agents must **never guess** `./configure` flags or dependency trees when adding a new C-library to the distroless foundations. You are explicitly instructed to use the Distroless Engine which fetches and parses Arch Linux `PKGBUILD` files as the primary intelligence reference.
- **FHS Unification:** The architecture unifies all shared libraries into `/usr/lib`. Standard symlinks (`/lib -> /usr/lib`, `/lib64 -> /usr/lib`) must be preserved to ensure kernel-level binary execution (ELF interpreter resolution).
- **NSS Networking:** The `base` image must always include the Name Service Switch (NSS) libraries (`libnss_dns.so.2`, `libresolv.so.2`) to ensure functional DNS resolution in minimal environments.
- **Debug Tagging Strategy:** Standard production images (`static`, `base`, `cc`, `runtime`) must remain **strictly zero-executable** (no shell). Troubleshooting utilities (Busybox) are only permitted in the `:debug` tagged variants.
- **License Compliance:** Every image must include the `LICENSE` files for all compiled components under `/usr/share/doc/<package>/`. This is handled automatically by the Distroless Engine.
- **Exec-Form Invocation:** Docker instructions must use **Exec Form** (e.g., `RUN ["/usr/bin/python", "-m", "http.server"]`) to invoke syscall processes directly.

## 3. Mandatory Security Implementations
When generating or modifying the Distroless Engine or Bake definitions, you must include the following:
1. **ABI Spec Enforcement:** Core libraries must be compiled with hardened ABI flags (`-fstack-protector-strong`, `-D_FORTIFY_SOURCE=2`).
2. **Linkage Guard:** Enforce global `LDFLAGS` (`-Wl,-rpath,/usr/lib`) to prioritize the project's own foundations.
3. **Keyless Signing:** All final images and intermediate targets must be signed using Sigstore/Cosign OIDC Keyless mechanisms.
4. **SLSA Level 3:** Non-falsifiable build attestations for every layer.

## 4. Technical Communication & Documentation Standards
- **Professional Engineering Tone:** Documentation must be written as objective technical specifications. Avoid first-person narratives ("We discovered", "I found").
- **Strict Anti-AI Style:** 
    - **No Emojis:** The use of emojis in technical documentation (README, AGENT.md, docs/) is strictly prohibited.
    - **No Meta-Transitions:** Avoid explaining internal process changes (e.g., "We have transitioned to..."). Documentation must describe the **current state** of the architecture directly.
    - **No Filler Content:** Documentation must be concise and focus on implementation details. Avoid repetitive summaries or marketing-style buzzwords.
- **Architectural Traceability:** Every change to the core logic must be reflected in the project `README.md` and relevant technical docs, ensuring the "source of truth" is always updated to the latest state.
- **Graphical Diagrams (Mermaid):** Technical flows must be visualized using Mermaid syntax and rendered to static assets.
- **Relative Repository Pathing:** Technical documentation must never utilize absolute local file URIs (e.g., `file:///Users/...` or `file:///absolute/path/...`). All internal file references and links within the codebase and markdown manuals must be defined using standard relative paths (e.g., `../engine/discovery.py`) to guarantee rendering portability and compatibility when pushed to GitHub.

## 5. Verification Protocol & Execution Safeguards
- **Mandatory Verification Execution:** Before concluding any structural changes to the Distroless Engine (`engine/engine.py`), foundations, or stack metadata, you must execute the automated test and assembly pipeline (`/scripts/assemble.sh` or standard compilation sequences) to verify 100% regression safety and binary correctness.
- **Static Security Scanning:** You must execute security SBOM scanning validation (`scripts/scan-sbom.py`) or equivalent image report sweeps to ensure the software supply chain has zero untracked dependencies or newly introduced CVE vulnerabilities.

## 6. State & Artifact Synchronization Rules
- **Task Verification Traceability:** In repositories utilizing planning and execution models, you must dynamically maintain the `task.md` checklist in the workspace, marking items as `[/]` (in-progress) or `[x]` (completed).
- **Post-Implementation Documentation:** Every resolved instruction set must compile a clear system log inside `walkthrough.md` documenting exact code changes, test validations, and execution findings.
