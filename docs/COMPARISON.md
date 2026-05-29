# Container Base Image Comparison: Architectural & Operational Analysis

Building secure container images requires addressing several requirements: filesystem layout, compiler compatibility, open-source licensing, and supply chain security. This document compares different base image strategies to help select the appropriate approach for production environments.

---

## 1. Image Classification and Selection Criteria

When selecting a base image strategy, organizations should evaluate long-term maintenance, license compliance, developer usability, and security patching methods, rather than just comparing initial image sizes. This section outlines five base image architectural types and eight operational questions to guide this evaluation.

### 1.1 Image Architectural Types
1. **Source-Compiled Distroless (This Project)**: Custom-compiled shared libraries built directly from upstream vendor source tarballs via an ephemeral toolchain. This approach avoids using packages from standard Linux distributions, resulting in a minimal filesystem footprint with no package managers or shells.
2. **Binary-Extracted Distroless** *(e.g., Google Distroless, Chainguard)*: Extracts pre-compiled binaries from standard OS packages (such as Debian or Wolfi) and bundles them into shell-free images without package managers.
3. **Minimal OS Runtimes** *(e.g., Red Hat UBI-micro, SUSE BCI-micro, Bitnami)*: Stripped-down configurations of commercial or standard Linux distributions that omit shells and package managers in production tags but retain the vendor's package database and lifecycle tracking.
4. **In-Place Library Patching** *(e.g., Root.io)*: Evaluates existing OCI images and replaces vulnerable shared libraries (`.so` files) directly in-place, keeping the original filesystem structure and package database.
5. **Standard Base OS** *(e.g., Ubuntu, Alpine)*: Traditional Linux distributions that include a package manager, shell, and core system utilities.

### 1.2 Eight Standardized Day-2 Operational Questions
1. **Image Sourcing**: Where do libraries and binaries originate? (Source code tarballs vs. pre-compiled OS package distributions).
2. **Runtime Attack Surface**: Are package managers, shells, or debugging tools included in production tags?
3. **Dependency Modularity**: Can the image include only the exact shared libraries needed for the runtime, or does it inherit a pre-defined bundle of unused libraries?
4. **Image Customization**: How are custom root CA certificates, configuration files, and troubleshooting tools added to the image?
5. **Vulnerability Patching**: How are security vulnerabilities (CVEs) resolved? (Full rebuilds vs. in-place binary patching).
6. **License Compliance**: How are open-source software licenses gathered and indexed for compliance audits?
7. **Vulnerability Scanner Support**: Do standard security scanners accurately report vulnerabilities without false-negatives (due to missing package databases) or false-positives?
8. **Maintenance Lifecycle**: What is the administrative overhead for managing version tags and updates across the container fleet?

---

## 2. Comparative Evaluation Matrices

To ensure readability and prevent horizontal visual squishing, the comparison matrix is organized into three targeted thematic matrices corresponding to core enterprise operational stakeholders.

### 2.1 Matrix 1: Build & Development Experience (For Developers & Architects)

This matrix maps columns related to compiling, customizing, modularity, and run-time attack surface to evaluate initial development complexity and filesystem boundaries.

| Container OS / Solution | Sourcing & Provenance (Q1) | Operational Attack Surface (Q2) | Customization & Extensibility (Q4) | Dependency Bloat & Modularity (Q3) |
| :--- | :--- | :--- | :--- | :--- |
| **Standard OS Base** *(Ubuntu / Alpine)* | Pre-compiled binary packages via OS package managers (`apt`, `apk`). | Retains shell (`bash`/`sh`), package manager, `coreutils`, and networking tools. | **Extensible / Conventional**. Customizations are straightforward using the standard package manager (`apt-get install` or `apk add`) and standard directories. | **Coarse-grained**. Standard package installations pull in dynamic dependency trees including documentation, test suites, and optional utilities. |
| **Google Distroless** *(`gcr.io/distroless`)* | Pre-compiled libraries extracted from Debian package files. | No shell or package manager present in standard production tags. | **Rigid**. Customizations (such as adding libraries or CA certificates) require modifying upstream Bazel configuration rules and rebuilding the base layers. Production tags omit diagnostic tools; developers must use parallel `:debug` tags. | **Coarse-grained**. Monolithic runtime stages contain a pre-defined bundle of libraries (glibc, libstdc++, libgcc) compiled globally for C++ runtimes. |
| **Chainguard Images** *(`apko` / `melange`)* | Source packages built into minimal custom APK archives via the `melange` builder. | No shell or package manager present in standard production tags. | **Declarative**. Customizations are declared in custom `apko` and `melange` YAML configuration definitions. Production tags omit diagnostic tools; developers use parallel `:debug` tags for troubleshooting. | **Fine-grained**. Declaratively compiles and includes minimal APK package dependencies, relying on Wolfi package repositories. |
| **Red Hat UBI** *(UBI-micro / Standard)* | Enterprise RPM packages sourced from RHEL package repositories. | Standard and minimal tags contain `microdnf` and `bash`. UBI-micro is shell-free. | **Package-Driven**. Minimal and standard tags are extensible using standard RPM repositories via `dnf` or `microdnf`. Certificates and custom packages follow standard paths. | **Coarse-grained**. Includes standard enterprise packages required for RHEL runtime compatibility and corporate certification. |
| **SUSE BCI** *(BCI-micro / Standard)* | Enterprise RPM packages sourced from SLES package repositories. | Standard tags include `zypper` and `sh`. BCI-micro is shell-free. | **Package-Driven**. Easily extensible using the `zypper` package manager in standard variants. BCI-micro requires multi-stage Docker builds to copy files but retains SLES directory paths. | **Coarse-grained**. Includes standard SLES-based dynamic library package bundles required for enterprise compliance and support. |
| **Bitnami Images** | Minimal Photon OS RPM-based base layers with packaged developer runtimes. | Retains Photon OS utilities, shell (`bash`/`sh`), `tdnf` package manager, and custom startup scripts. | **Script / Package-Driven**. Extensible via the Photon OS `tdnf` package manager or custom startup scripts. Merges standard base directories with custom `/opt/bitnami/` paths. | **Coarse-grained**. Custom developer runtime layers overlaid on a standard minimal OS package layout. |
| **Hummingbird** | Custom RPM packages compiled from Fedora specifications via Konflux. | No shell or package manager in production tags; builder variants include DNF. | **Declarative**. Customizations must be integrated via Konflux build specifications using custom RPM definitions. Follows standard Fedora paths for certificates and library locations. | **Fine-grained**. Builds minimal images via Konflux using layer-level content deduplication (via the `chunkah` tool). |
| **Minimus** | Pre-compiled static libraries or dynamic runtimes built via manual linkage. | Omits shells and dynamic interpreters unless explicitly copied into the image. | **Manual File Copying**. Requires writing manual Dockerfile COPY instructions to inject files, certificates, or libraries. Prone to path resolution issues due to the lack of an orchestrated packaging structure. | **Ad-hoc**. Manual copying of dynamic libraries compiled on local hosts, lacking automated dependency management. |
| **Root.io** | Automated patching of dynamic libraries and package dependencies on existing base images. | Inherits the attack surface of the upstream base image, patching specific vulnerable library packages. | **Upstream-Inherited**. Retains the baseline image's standard customization methods. Certificates and libraries are added using normal base OS operations prior to the library patching process. | **Coarse-grained**. Modifies existing base images in-place, keeping the original package manager metadata. |
| **Distroless The Hard Way** *(Our Solution)* | Compiled from upstream vendor source tarballs via an ephemeral toolchain. | No shell, package manager, or system utilities in production tags. | **Atoms-Driven**. Customizations are configured in `engine/config.yaml` and stacked as OCI Atoms in a custom `stacks/*.yaml`. Debugging tools and root certificates are added via clean overlay layers (shells are restricted to `:debug` tags). | **Fine-grained**. The build engine compiles and includes only the specific dynamic shared libraries required for the runtime stack. |

---

### 2.2 Matrix 2: Governance, Compliance & Risk Management (For CISO & Legal)

This matrix maps columns related to open-source compliance auditing, cryptographic supply chain signatures, and legal provenance to evaluate corporate risk metrics.

| Container OS / Solution | Related Sourcing Site | Legal & Compliance Auditing (Q6) | Trust Signatures & Attestations (Q5) |
| :--- | :--- | :--- | :--- |
| **Standard OS Base** *(Ubuntu / Alpine)* | [ubuntu.com](https://ubuntu.com) / [alpinelinux.org](https://alpinelinux.org) | Fragmented. Retains package metadata databases, but lacks isolated license aggregation. | Omit native SLSA Level 3 attestations or Cosign signatures. |
| **Google Distroless** *(`gcr.io/distroless`)* | [github.com/GoogleContainerTools/distroless](https://github.com/GoogleContainerTools/distroless) | Partial. Retains system-wide license catalogs but does not isolate specific source licenses. | Keyless Sigstore signing and SLSA provenance attestations linked to OIDC. |
| **Chainguard Images** *(`apko` / `melange`)* | [chainguard.dev/chainguard-images](https://www.chainguard.dev/chainguard-images) | Automated. Metadata-driven license extraction derived directly from APK specifications. | Complete. Full SLSA Level 3 attestations, SBOM generation, and Cosign OIDC signing. |
| **Red Hat UBI** *(UBI-micro / Standard)* | [redhat.com/en/universal-base-image](https://redhat.com/en/technologies/linux-platforms/universal-base-image) | Retained within system RPM databases, but lacks separate standalone license extraction. | Red Hat GPG-signed RPMs and basic image registry signatures. |
| **SUSE BCI** *(BCI-micro / Standard)* | [suse.com/base-container-images](https://www.suse.com/products/base-container-images) | Standard RPM database registration. | SUSE GPG-signed RPMs and basic image registry signatures. |
| **Bitnami Images** | [bitnami.com](https://bitnami.com) | Standard RPM package databases; requires manual compliance audits. | Basic registry signatures and automated vulnerability scanning reports. |
| **Hummingbird** | [gitlab.com/redhat/hummingbird/containers](https://gitlab.com/redhat/hummingbird/containers) / [images.redhat.com](https://images.redhat.com/) | Custom metadata-driven compliance integrated into the Konflux build loop. | Full Konflux SLSA Level 3 attestations, SBOMs, and Cosign keyless signing. |
| **Minimus** | [https://www.minimus.io/](https://www.minimus.io/) / [docs.minimus.io](https://docs.minimus.io/) | Manual tracking; lacks automated license aggregation. | Basic registry-level metadata validation. |
| **Root.io** | [root.io](https://root.io/) / [docs.root.io](https://docs.root.io/) | Retains all upstream package manager metadata and licenses of the baseline image. | Dynamic patch signing, cryptographically verifying automated remediation steps. |
| **Distroless The Hard Way** *(Our Solution)* | [github.com/mbuccarello/distroless-the-hard-way](https://github.com/mbuccarello/distroless-the-hard-way) | **Automated License Harvesting**. The build engine automatically extracts licenses from source archives and saves them under `/usr/share/doc/<package>/` for every library built. | **High-Assurance Chain-of-Trust**. Full SLSA Level 3 attestations, Syft CycloneDX SBOM generation, and Cosign OIDC verification. |

---

### 2.3 Matrix 3: Day-2 Maintenance & Incident Response (For DevSecOps & Security Ops)

This matrix maps columns related to active security patch deployment, vulnerability scanning transparency, and version tracking overhead to evaluate long-term maintenance requirements.

| Container OS / Solution | Vulnerability Scanner Efficacy (Q7) | Vulnerability Patching Loop (Q5) | Version Tracking & Maintenance Overhead (Q8) |
| :--- | :--- | :--- | :--- |
| **Standard OS Base** *(Ubuntu / Alpine)* | **Native Support**. Scanners (Trivy, Grype, Snyk) parse the standard package databases (`dpkg`/`apk`) to resolve CVEs. | **Release-based / Manual**. Rebuilds are published by the distribution maintainers; security compliance requires developers to run package upgrades or pull updated base revisions. | **High**. Dozens of version tags (e.g., `22.04`, `3.19`). Developers must track upstream refreshes and run manual updates or rebuild applications. |
| **Google Distroless** *(`gcr.io/distroless`)* | **High**. Resolves package databases via a decentralized structure at `/var/lib/dpkg/status.d/<package>` (specified in [PACKAGE_METADATA.md](https://github.com/GoogleContainerTools/distroless/blob/e12be8b2e2a4366f0d9b007adeb17ffddbcfba72/PACKAGE_METADATA.md)), allowing scanners to parse CVEs without layered build merge conflicts. | **Weekly Automated Rebuilds**. Floating runtime family tags are updated weekly via automated base package rebuilds from Debian repositories; snapshot tags are frozen. | **Moderate**. Under 20 floating runtime tags. Only active floating tags receive weekly security updates; developers must monitor snapshot tags to manage deployments. |
| **Chainguard Images** *(`apko` / `melange`)* | **High / Integrated**. Natively verified by partner scanners (Trivy, Grype, Snyk, Wiz; see the [Compatibility List](https://www.chainguard.dev/scanners)). Continuously publishes OSV-compliant advisory feeds derived from git-managed YAML databases (refer to [foundational_concepts.md](https://github.com/chainguard-dev/vulnerability-scanner-support/blob/main/docs/foundational_concepts.md)). | **Continuous Automated Rebuilds**. Floating tags are rebuilt automatically (daily or multiple times a day) if package security updates are available in Wolfi APK repositories. | **High Rebuild Frequency**. Thousands of active floating tags rebuilt continuously. Requires DevOps teams to automate continuous integration (CI) pull loops to keep up with daily patch releases. |
| **Red Hat UBI** *(UBI-micro / Standard)* | **Native Support**. Because UBI inherits RHEL's standard filesystem hierarchy and RPM database structure (`/var/lib/rpm`), standard scanners recognize it natively and map packages against official Red Hat Security Advisories (RHSA) and OVAL feeds. | **Monthly Enterprise Refreshes**. Floating tags receive regular (usually monthly) base package updates via Red Hat RPM repositories. | **Low to Moderate**. Enterprise lifecycle tags maintained under strict SLAs. Monthly updates reduce rebuild churn compared to rapid rolling distributions. |
| **SUSE BCI** *(BCI-micro / Standard)* | **Native Support**. Because SUSE BCI inherits SLES's filesystem hierarchy and RPM database layout (similar to Red Hat's UBI model; refer to the [SUSE BCI FAQ](https://www.suse.com/products/base-container-images/faq/)), standard scanners recognize it natively and map components against official SUSE CVE databases. | **Periodic Automated Rebuilds**. Floating tags receive periodic RPM package updates aligned with SLES security releases. | **Low to Moderate**. Version tags match supported SLES iterations, providing predictable maintenance windows and stable enterprise lifecycles. |
| **Bitnami Images** | **Limited**. Vulnerability scanning support is limited to **Trivy** and **Grype** (refer to the [Bitnami Container Vulnerability Scan Spec](https://github.com/bitnami/containers#vulnerability-scan-in-bitnami-container-images)). | **Automated Pipeline Rebuilds**. Images are rebuilt and scanned automatically when underlying Photon OS system libraries receive package updates. | **Moderate to High**. Hundreds of dynamic developer revision tags. Developers must monitor revision tags closely to keep dependencies up-to-date. |
| **Hummingbird** | **Progressive**. Full support for **Anchore Enterprise** and **Grype** via Red Hat security feeds, with support for **Trivy**, **Clair**, **RHACS**, and **Aqua** in progress (refer to the [Red Hat Security Feed](https://images.redhat.com/security-feed)). | **Konflux Build Spec Rebuilding**. Rebuilds are automatically triggered when updated RPM dependency layers or Fedora security definitions change in the Konflux system. | **Moderate**. Version tags are tied to Fedora base specs and Konflux builds, updating dynamically when layer definitions change. |
| **Minimus** | **Broad / Native**. Supported by scanners including **AWS (Amazon Inspector)**, **Black Duck**, **GCP**, **Grype**, **Microsoft Azure**, **Orca**, **Snyk**, **Trivy**, and **Wiz**; other scanners integrate via the custom Advisories Feed (refer to the [Minimus Scanner Support Spec](https://docs.minimus.io/scanning/scanner-support)). | **Ad-hoc Manual Upgrades**. No automated patching mechanism exists; security updates require manual build triggers and application redeployments. | **Extremely High / Manual**. Minimal rolling tags. Remediating CVEs requires manual engineering rebuilds, causing operational overhead and compliance delays. |
| **Root.io** | **Broad / Compatible**. Recognized by scanners including **Grype**, **Trivy**, **Wiz**, **Orca Security**, **Sysdig**, **Ox Security**, **Mend**, **GitLab**, **VMware Harbor**, **Qualys**, **Jit**, **Rancher**, and **Datadog** (refer to the [Root.io Scanner Compatibility Spec](https://docs.root.io/integrations/scanner-compatibility#scanner-compatibility)). | **In-Place Dynamic Patching**. Patches vulnerabilities in-place on existing tags by replacing vulnerable system libraries directly, without rebuilding the container from scratch. | **Minimal**. Patching is applied directly to active OCI tags, preserving standard tags and filesystems without scratch rebuild overhead. |
| **Distroless The Hard Way** *(Our Solution)* | **SBOM Audited**. Generates exhaustive **CycloneDX SBOMs (Syft)** during compilation and executes **Grype scans directly against the SBOM metadata**. This resolves scanner database dependencies and ensures all libraries are tracked. | **Automated Atomized Rebuild Loop**. The build orchestrator monitors upstream library sources, compiles updated OCI Atoms, and automatically rebuilds target runtime stacks with full attestations. | **Automated Atomized Rebuild Loop**. The orchestrator automates source-recompilation of dynamic libraries and stacks. Developers maintain stable semantic tags with zero administrative overhead. |

---

## 3. Technical Implementation Details

Achieving true production readiness without inheriting an entire operating system introduces several system-engineering challenges that this project resolves:

### 3.1 Dynamic Library Resolution
When compiling runtimes (such as Python or PHP) from source, the dynamic linker (`ld.so`) must locate and resolve dynamic shared libraries (such as OpenSSL or SQLite) at runtime. Traditional operating systems use a central configuration cache (`ldconfig`) to locate libraries across multiple paths. 

This project achieves deterministic library resolution by:
*   Enforcing a unified directory structure where `/lib` and `/lib64` are absolute symlinks pointing to `/usr/lib` and `/usr/lib64`.
*   Pinning the library lookup path of compiled binaries to `/usr/lib` using linker flags (`-Wl,-rpath,/usr/lib`). This prevents lookup path hijacking and ensures rapid library resolution.

### 3.2 License Aggregation
Distributing compiled dynamic libraries without their corresponding upstream licenses can violate open-source compliance requirements (such as MIT, BSD, or Apache licensing). 

While traditional distributions rely on package databases, minimal distroless environments omit these metadata files. The build engine resolves this by automatically extracting `LICENSE` and `COPYING` files during compilation and saving them to `/usr/share/doc/<package>/` for every dynamic library built.

### 3.3 Supply Chain Security and Attestations
Enterprise container deployments often require cryptographic verification of the build origin and integrity before execution. 

This project implements this using Buildkit metadata exports and **Sigstore/Cosign**. Keyless OpenID Connect (OIDC) signatures bind the container image digest directly to the GitHub Actions build workflow identity. This ensures only images built in the audited build pipeline can run in production.

### 3.4 Scanner Compatibility and Package Registries
Many standard security scanners (such as Trivy, Snyk, and Grype) identify vulnerabilities by parsing package manager databases (such as `/var/lib/dpkg` or `/lib/apk/db`). 

Because custom source-compiled dynamic libraries do not register in an OS package manager database, standard scanners fail to detect them. This results in a false-negative "zero vulnerability" report, obscuring outdated, vulnerable libraries in production.

To address this, other solutions and this project use different registry methods:
*   **Google Distroless** uses a decentralized status registry under `/var/lib/dpkg/status.d/<package>` (specified in [PACKAGE_METADATA.md](https://github.com/GoogleContainerTools/distroless/blob/e12be8b2e2a4366f0d9b007adeb17ffddbcfba72/PACKAGE_METADATA.md)), allowing scanners to parse Debian vulnerabilities cleanly without layered database locks.
*   **Chainguard** integrates natively with security vendors and publishes continuous OSV-compliant advisory feeds derived from git-managed YAML databases (refer to [foundational_concepts.md](https://github.com/chainguard-dev/vulnerability-scanner-support/blob/main/docs/foundational_concepts.md)). Scanners query the APK database to map installed files to packages.
*   **Minimus** provides native integration with major cloud and third-party scanning platforms and publishes a dedicated advisories feed (refer to [scanning/scanner-support](https://docs.minimus.io/scanning/scanner-support)).
*   **Root.io** preserves the upstream package database and filesystems, allowing standard scanners to recognize patched packages and report correct, remediated CVE counts (refer to [integrations/scanner-compatibility](https://docs.root.io/integrations/scanner-compatibility)).
*   **This project** uses **Syft** to generate a **CycloneDX Software Bill of Materials (SBOM)** during the build process, and runs **Grype scans directly against this SBOM**. This bypasses the package database requirement and ensures all source-compiled components are tracked and audited.

---

> For details on the build scripts and orchestration, see the **[Distroless Engine Documentation](ENGINE.md)**.
> For details on the CI/CD workflows, see the **[Pipelines Documentation](PIPELINES.md)**.
