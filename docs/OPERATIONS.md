# Sovereign Distroless: Operations, Maintenance & Testing

This document defines the Day-2 operations, version maintenance policy, verification testing framework, and runtime configurations for the **Distroless The Hard Way** ecosystem.

---

## 1. Lifecycle & Maintenance

### 1.1 Version Selection Policy
The project prioritizes stability and long-term support (LTS) for runtimes and core libraries:
- **Core Libraries**: Track the latest stable releases provided by the official Arch Linux package databases.
- **Runtimes**: Focus on active LTS families (e.g., Python 3.14, Node.js 22, .NET 8).
- **Pinning**: All versions are pinned in `stacks/*.yaml` to ensure absolute build reproducibility.

### 1.2 Patching Process
Security patches are applied systematically:
1. **Upstream Detection**: The engine checks for new releases of foundational packages.
2. **Cascading Rebuilds**: Any update to a foundation layer (e.g., `openssl` or `glibc`) automatically triggers a full compilation cascade of all downstream OCI images and dependent stacks.
3. **Verification**: Re-compiled images must successfully pass the end-to-end (E2E) verification test suite before deployment.

---

## 2. Testing & Verification

### 2.1 E2E Verification Framework
The project implements a strict, automated end-to-end testing pipeline:
- **Test Workflow**: [`.github/workflows/distroless-e2e.yml`](../.github/workflows/distroless-e2e.yml) validates every generated image.
- **Test Matrix**: Each language stack defines a verification application (e.g., `test.py`, `test.js`, `test.java`) in `app/`.
- **Validation Logic**: Tests verify basic binary execution, successful loading of dynamic shared libraries (ABI compatibility checks), and HTTPS connectivity against the root trust store (SSL verification).

### 2.2 Debugging Strategy
Standard production images contain zero executables (no shell). Diagnostic and troubleshooting operations leverage the corresponding `:debug` image variants:
- **Diagnostic Shell**: Includes a minimal, unprivileged Busybox shell environment.
- **Usage**: Run `docker run --rm -it <image>:debug /bin/sh` to inspect the container filesystem, check network endpoints, or debug runtime execution.

---

## 3. Local Development

To construct and validate a specific stack or dependency locally:
1. **Definition Generation**: Run `python3 engine/engine.py --mode runtime --stack stacks/<name>.yaml` to generate Dockerfiles and HCL targets.
2. **Build Execution**: Run `docker buildx bake -f foundations/<name>.hcl runtime-debug` to compile the targets.
3. **Local Verification**: Start the generated image with the `:debug` tag to inspect the resulting filesystem.

---

## 4. Custom CA Certificates Support

Distroless images can be configured to trust corporate or custom Certificate Authorities (CAs) for secure internal networking or enterprise TLS interception proxies.

### 4.1 OpenSSL-Based Runtimes (Python, PHP, Perl, curl, etc.)
OpenSSL-based environments search for certificate bundles in the ununified path `/etc/ssl/certs/ca-certificates.crt`. To mount a custom CA bundle at runtime, map the host certificate file as a read-only volume:

```bash
docker run --rm \
  -v /path/to/my-company-ca.crt:/etc/ssl/certs/ca-certificates.crt:ro \
  ghcr.io/mbuccarello/python-distroless:latest python3 -c "import urllib.request; print(urllib.request.urlopen('https://internal-secure-site/').read())"
```

> [!NOTE]
> The mounted certificate bundle must contain both the custom enterprise certificates and standard public root CAs if the containerized application is required to resolve external public endpoints.

---

### 4.2 Java-Based Runtimes (OpenJDK)
Java runtimes store root certificates in a proprietary truststore format (`cacerts` in PKCS12 format) located at `/etc/pki/ca-trust/extracted/java/cacerts`.

To inject a custom CA into a Java distroless environment:
1. Extract and import the custom certificate into a local `cacerts` file using the Java `keytool` command (the standard truststore password is "changeit"):
   ```bash
   # Retrieve the baseline truststore from the debug container
   docker run --rm --entrypoint cat ghcr.io/mbuccarello/java-distroless:debug /etc/pki/ca-trust/extracted/java/cacerts > ./cacerts
   
   # Import the custom root certificate
   keytool -importcert -trustcacerts \
     -file /path/to/my-ca.crt \
     -alias my-custom-ca \
     -keystore ./cacerts \
     -storepass changeit -noprompt
   ```
2. Mount the modified `cacerts` file to the ununified runtime truststore path:
   ```bash
   docker run --rm \
     -v $(pwd)/cacerts:/etc/pki/ca-trust/extracted/java/cacerts:ro \
     ghcr.io/mbuccarello/java-distroless:latest -jar app.jar
   ```

---

## 5. Operational Maintenance: Package Upgrades and New Atoms

The Distroless Orchestrator separates concerns by externalizing build configurations from the Python logic. All package definitions, source URLs, dependency overrides, and custom compilation arguments are stored in the central matrix: `engine/config.yaml`.

### 5.1 Upgrading a Foundational Package
When a package (e.g., `openssl` or `libxcrypt`) requires a security update or patch bump, follow these steps:
1. Locate the package in the `sources` mapping of `engine/config.yaml`.
2. Update the source archive URL to the target version release.
3. If the upgrade requires adjusting compilation arguments (e.g., handling deprecated features or new security flags), locate the corresponding package in the `packages` list and update its `config` arguments.
4. Regenerate all build definitions by running:
   ```bash
   python3 engine/engine.py --mode foundation
   python3 engine/engine.py --mode runtime --stack stacks/<stack_name>.yaml
   ```
5. Commit the changes and push them. The CI pipeline will automatically run a cascading build of all downstream images to apply the security update.

### 5.2 Introducing a Custom Compilation Flag
To add a compiler feature or hardening flag (e.g., adjusting `./configure` options for size or security optimization):
1. Locate the package in the `packages` mapping of `engine/config.yaml`.
2. Add or modify the arguments under `config`.
3. Document the systems-engineering rationale for the new compiler flag directly in `engine/config.yaml` as comments, and mirror the explanation in `docs/ENGINE.md` under the "Package Configure Hardening Catalog".
4. Re-run `engine/engine.py` to regenerate the HCL configuration targets.
