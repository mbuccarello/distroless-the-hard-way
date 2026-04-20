# Version Selection Strategy (Source-to-OCI)

In a **Source-to-OCI** model, we bear the cryptographic responsibility for every binary in our images. Identifying the "right" version for a library like `glibc` or `openssl` is not about choosing the highest number, but about balancing **Security**, **ABI Stability**, and **Runtime Compatibility**.

This document outlines the ground-up strategy for selecting foundational library versions within Distroless-The-Hard-Way.

---

## 🏗 1. The Core Hierarchy

We classify our components into three distinct tiers, each with a unique versioning strategy.

### Tier 1: The Foundations (`glibc`, `musl`)
*   **Role**: Bedrock ABI (Application Binary Interface).
*   **Strategy**: **"Near-Modern Baseline"**.
*   **Selection Rule**: Target the `glibc` version used by the current **Debian Stable** or **Ubuntu LTS**.
*   **Rationale**: `glibc` is a "one-way street." Binaries compiled against a newer `glibc` will **not** run on an older one. Matching the community stable baseline ensures that our SDKs and language runtimes (like Java/Node) remain compatible with a wide range of pre-built tools if necessary.

### Tier 2: Security Criticals (`openssl`, `zlib`, `lz4`)
*   **Role**: Cryptography and shared utilities.
*   **Strategy**: **"Aggressive Latest Stable"**.
*   **Selection Rule**: Always use the **latest patch** of the current major branch.
*   **Rationale**: These libraries are the primary targets for attackers (CVE-intensive). Because they don't break the global ABI like `glibc` does, we can pivot instantly to a new patch release the moment a vulnerability is announced.

### Tier 3: High-Level Runtimes (`node`, `openjdk`, `dotnet`)
*   **Role**: Application execution.
*   **Strategy**: **"Certified LTS"**.
*   **Selection Rule**: Target the **Long Term Support (LTS)** releases.
*   **Rationale**: Enterprise applications require predictability. We choose the version that has the longest maintenance window from the upstream provider.

---

## 📊 2. Selection Criteria (The "Four Pillars")

When a new version is released, it must pass these four gates before being promoted to a Blueprint:

| Pillar | Question | Metric |
| :--- | :--- | :--- |
| **Pillar 1: Security** | Are there known CVEs in the proposed version? | 0 Critical/High CVEs. |
| **Pillar 2: Stability** | Has it been in a major distribution for > 3 months? | Community "Proof of Work". |
| **Pillar 3: Logic** | Does it pass our E2E verification suite? | SSL Handshake + Timezone integrity. |
| **Pillar 4: Support** | Is the upstream project still maintaining this branch? | Active life-cycle. |

---

## 🚦 3. The Upgrade Workflow

We do not perform "silent" upgrades. Every version change follows this cycle:

1.  **Draft**: Update the Blueprint version (e.g., `2.39` $\rightarrow$ `2.40`).
2.  **Verify**: Run the E2E verification workflows for all runtimes (Java, Node, .NET).
3.  **Audit**: Check the SBOM of the new image for regression in vulnerability counts.
4.  **Promote**: Merge the PR and publish the new `:latest` and `:vX.Y.Z` tags.

---

## 🎯 4. Practical Recommendation: The `glibc` "LTS" Rule

For a high-assurance distro, we recommend **not** using the "bleeding edge" `glibc`.
*   **Good**: `glibc 2.39` (Stable, patched, widely supported in runtimes).
*   **Risky**: `glibc 2.41-rc1` (Potential for kernel compatibility issues or runtime crashes).

---

## 🛠 5. The Power to Patch: Custom Security Backporting

Because Distroless-The-Hard-Way is a **Source-to-OCI** engine, we are not passive consumers of binaries. We are the "Upstream Maintainers" of our own infrastructure. This gives us the **Power to Patch**.

### Why Patch instead of Upgrade?
When a high-severity CVE is announced for a foundational library like `glibc 2.36`, but the "official" fix is only available in `glibc 2.39`, a standard distribution would force you to upgrade the entire OS layer. 
*   **The Risk**: Upgrading `glibc` might break the ABI for older Java or .NET runtimes.
*   **The Solution**: We stay on `glibc 2.36` (the proven stable version) and **backport** the specific security fix.

### How Security Patching Works (Deterministic Flow)

1.  **Identify the Fix**: Locate the specific commit or `.patch` file from the upstream project (e.g., GNU Libc, OpenSSL).
2.  **Verify Applicability**: Ensure the patch applies cleanly to our current version.
3.  **Deterministic Injection**: Add the patch to the Blueprint's `build_steps`.

**Example Blueprint Entry:**
```yaml
sources:
  - url: "https://ftp.gnu.org/gnu/glibc/glibc-2.36.tar.gz"
  - url: "https://security.debian.org/patches/glibc-cve-2024-XXXX.patch" # Security Fix
build_steps:
  - "cd src_glibc && patch -p1 < ../glibc-cve-2024-XXXX.patch" # Backport the Fix
  - "cd src_glibc && ./configure --prefix=/usr && make install"
```

### 🛡 The Zero-Trust Advantage
*   **Minimal Surface Area**: We only change the vulnerable lines of code, leaving the rest of the stable library untouched.
*   **Immediate Response**: We can apply a patch the hour it is released, often days before a traditional OS vendor releases an updated `.deb` or `.rpm`.
*   **SBOM Integrity**: The patch is documented in the build logs and the resulting SBOM, providing full cryptographic transparency of the fix.

---

## 📅 6. Library-Specific LTS & Support Patterns

To maintain a high-assurance environment, we align our Blueprints with the following upstream support cycles.

### 🐧 The Basic Foundations
*   **glibc (GNU C Library)**: Upstream releases a new version every 6 months. While they briefly support old branches, we rely on **Debian/RHEL backports** for long-term stability. 
    *   *Pattern*: We follow the **OS-Distribution LTS** cycle (e.g., matching the `glibc` in Ubuntu 24.04 LTS).
*   **Linux Kernel Headers**: Backward compatibility is the "Golden Rule" of Linux.
    *   *Pattern*: We use the **LTS Kernel Headers** (e.g., 6.1, 6.6) to ensure our binaries run on older host kernels.

### 🔐 Security & Cryptography
*   **OpenSSL**: Explicitly designates **LTS releases** (e.g., 3.0 is LTS, supported until Sept 2026).
    *   *Pattern*: We only host **LTS branches** for the base stack. We never move to a non-LTS major branch (like 3.2) unless it provides a critical security feature.

### ☕ Application Runtimes
*   **Node.js**: Uses an "Even-Numbered" LTS cycle.
    *   *Pattern*: We only provide Blueprints for **Even versions** (18, 20, 22). Support typically lasts **30 months**.
*   **OpenJDK**: LTS releases occur every 2 years (11, 17, 21).
    *   *Pattern*: We target **LTS versions** with a minimum of **5 years** of upstream support.
*   **dotnet (.NET)**: Releases an LTS every 2 years (6.0, 8.0).
    *   *Pattern*: We only support **LTS versions** which receive **3 years** of patches.

---

> [!TIP]
> This strategy essentially turns your organization into a **Security-Hardened Distribution Vendor**. You rely on the community for the "Logic" but take full responsibility for the "Integrity".
