# Security Patches: `curl`

- **Pinned source (from `engine/config.yaml`)**: https://github.com/curl/curl/releases/download/curl-8_11_0/curl-8.11.0.tar.gz
- **Upstream repository** (to locate/verify a fix commit): https://github.com/curl/curl
- **Security advisories**: [curl.se/docs/vulnerabilities.html](https://curl.se/docs/vulnerabilities.html) — a version-by-version vulnerability table plus a dedicated page per CVE (`curl.se/docs/CVE-YYYY-NNNNN.html`). One of the best-maintained lists of any Atom here.
- **Build config** (from `engine/config.yaml`, `packages.curl`): `--with-openssl=/opt/distroless --with-zlib=/opt/distroless --with-nghttp2=/opt/distroless --with-ca-bundle=/etc/ssl/certs/ca-certificates.crt --without-libpsl`


## 1. Check whether a patch is actually needed

Prefer bumping the pinned version over patching — see the decision rule in [`patches/README.md`](../README.md). Check first:

```bash
python3 scripts/scan-sbom.py stacks/
```

If it flags `curl`, or you already have a specific CVE from the advisory page above, continue below.

## 2. Get the exact pinned source

```bash
mkdir -p /tmp/curl-patch-work && cd /tmp/curl-patch-work
curl -L "https://github.com/curl/curl/releases/download/curl-8_11_0/curl-8.11.0.tar.gz" -o source.tar.gz
mkdir -p orig fixed
tar -xf source.tar.gz -C orig --strip-components=1
tar -xf source.tar.gz -C fixed --strip-components=1
```

## 3. Produce the fix

**Option A — you have the exact upstream commit that fixes the CVE** (fastest, least error-prone):

```bash
git clone --filter=blob:none https://github.com/curl/curl /tmp/curl-git
cd /tmp/curl-git
git format-patch -1 <commit-hash> --stdout > /Users/michele.buccarello/distroless-the-hard-way/patches/curl/0001-<short-description>.patch
```

**Option B — no single commit, or you need to hand-edit**:

```bash
# edit the affected file(s) under /tmp/curl-patch-work/fixed/...
cd /tmp/curl-patch-work
diff -u orig/<file> fixed/<file> | \
  sed "s|orig/|a/|; s|fixed/|b/|" > /Users/michele.buccarello/distroless-the-hard-way/patches/curl/0001-<short-description>.patch
```

Either way, the resulting file must be a standard unified diff applicable with `patch -p1` **from the extracted tarball root** (i.e. path prefixes are `a/...` and `b/...`, one path component stripped).

## 4. Test the patch before committing

```bash
cd /Users/michele.buccarello/distroless-the-hard-way
python3 engine/engine.py --mode foundation
docker buildx bake -f foundations/foundations.hcl curl --progress=plain 2>&1 | grep -iE "Applying patch|error|FAILED"
```

Look for `Applying patch: /tmp/patches/curl/...` followed by the build continuing normally. If the patch does not apply cleanly, `patch -p1` exits non-zero and the whole build fails at that exact step — there is no silent skip (see [`patches/README.md`](../README.md)).

## 5. Before committing

- Name the file `000N-<short-description>.patch` (numbered if more than one patch is needed for `curl`).
- Note the CVE ID and the source commit/advisory in the commit message.
- Remember: patching without a version bump makes the compiled binary's internal version string diverge from what it actually contains — see the scanner-detection tradeoff in [`patches/README.md`](../README.md#the-tradeoff-this-reintroduces).
