# Security Patches: `openssl`

- **Pinned source (from `engine/config.yaml`)**: https://github.com/openssl/openssl/releases/download/openssl-3.4.0/openssl-3.4.0.tar.gz
- **Upstream repository** (to locate/verify a fix commit): https://github.com/openssl/openssl
- **Security advisories**: [openssl-library.org/news/vulnerabilities](https://openssl-library.org/news/vulnerabilities/) — one dedicated entry per CVE, with affected/fixed version ranges. The best-maintained advisory page of any Atom in this project.
- **Build config** (from `engine/config.yaml`, `packages.openssl`): `shared zlib`


`config` here is passed to OpenSSL's own `./Configure` (capital C, not autoconf) — the engine detects this automatically via `runtime.Dockerfile`'s `[ -f ./Configure ]` check.

## 1. Check whether a patch is actually needed

Prefer bumping the pinned version over patching — see the decision rule in [`patches/README.md`](../README.md). Check first:

```bash
python3 scripts/scan-sbom.py stacks/
```

If it flags `openssl`, or you already have a specific CVE from the advisory page above, continue below.

## 2. Get the exact pinned source

```bash
mkdir -p /tmp/openssl-patch-work && cd /tmp/openssl-patch-work
curl -L "https://github.com/openssl/openssl/releases/download/openssl-3.4.0/openssl-3.4.0.tar.gz" -o source.tar.gz
mkdir -p orig fixed
tar -xf source.tar.gz -C orig --strip-components=1
tar -xf source.tar.gz -C fixed --strip-components=1
```

## 3. Produce the fix

**Option A — you have the exact upstream commit that fixes the CVE** (fastest, least error-prone):

```bash
git clone --filter=blob:none https://github.com/openssl/openssl /tmp/openssl-git
cd /tmp/openssl-git
git format-patch -1 <commit-hash> --stdout > /Users/michele.buccarello/distroless-the-hard-way/patches/openssl/0001-<short-description>.patch
```

**Option B — no single commit, or you need to hand-edit**:

```bash
# edit the affected file(s) under /tmp/openssl-patch-work/fixed/...
cd /tmp/openssl-patch-work
diff -u orig/<file> fixed/<file> | \
  sed "s|orig/|a/|; s|fixed/|b/|" > /Users/michele.buccarello/distroless-the-hard-way/patches/openssl/0001-<short-description>.patch
```

Either way, the resulting file must be a standard unified diff applicable with `patch -p1` **from the extracted tarball root** (i.e. path prefixes are `a/...` and `b/...`, one path component stripped).

## 4. Test the patch before committing

```bash
cd /Users/michele.buccarello/distroless-the-hard-way
python3 engine/engine.py --mode foundation
docker buildx bake -f foundations/foundations.hcl openssl --progress=plain 2>&1 | grep -iE "Applying patch|error|FAILED"
```

Look for `Applying patch: /tmp/patches/openssl/...` followed by the build continuing normally. If the patch does not apply cleanly, `patch -p1` exits non-zero and the whole build fails at that exact step — there is no silent skip (see [`patches/README.md`](../README.md)).

## 5. Before committing

- Name the file `000N-<short-description>.patch` (numbered if more than one patch is needed for `openssl`).
- Note the CVE ID and the source commit/advisory in the commit message.
- Remember: patching without a version bump makes the compiled binary's internal version string diverge from what it actually contains — see the scanner-detection tradeoff in [`patches/README.md`](../README.md#the-tradeoff-this-reintroduces).
