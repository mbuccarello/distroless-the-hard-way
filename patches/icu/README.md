# Security Patches: `icu`

- **Pinned source (from `engine/config.yaml`)**: https://github.com/unicode-org/icu/releases/download/release-75-1/icu4c-75_1-src.tgz
- **Upstream repository** (to locate/verify a fix commit): https://github.com/unicode-org/icu
- **Security advisories**: No dedicated page — check the GitHub Advisory Database and OSV.dev.
- **Build config** (from `engine/config.yaml`, `packages.icu`): `--enable-static --enable-shared --disable-tests --disable-samples --disable-extras --disable-icuio --disable-layoutex --disable-tools`

> **This Atom is installed via `dnf install -y libicu-devel` in this project, not compiled from the tarball above (see the `icu` special case in `engine.py`, `generate_runtime_dockerfile()`). A `patches/icu/*.patch` file would currently be copied into the build context but never applied — the patch-apply step only exists on the `curl`/`tar`/`./configure` code path, which `icu` does not take. Patching ICU here is not currently possible; track ICU CVEs through the Fedora `libicu`/`libicu-devel` package instead (`dnf changelog libicu`), since that's what actually gets installed.**


## 1. Check whether a patch is actually needed

Prefer bumping the pinned version over patching — see the decision rule in [`patches/README.md`](../README.md). Check first:

```bash
python3 scripts/scan-sbom.py stacks/
```

If it flags `icu`, or you already have a specific CVE from the advisory page above, continue below.

## 2. Get the exact pinned source

```bash
mkdir -p /tmp/icu-patch-work && cd /tmp/icu-patch-work
curl -L "https://github.com/unicode-org/icu/releases/download/release-75-1/icu4c-75_1-src.tgz" -o source.tar.gz
mkdir -p orig fixed
tar -xf source.tar.gz -C orig --strip-components=1
tar -xf source.tar.gz -C fixed --strip-components=1
```

## 3. Produce the fix

**Option A — you have the exact upstream commit that fixes the CVE** (fastest, least error-prone):

```bash
git clone --filter=blob:none https://github.com/unicode-org/icu /tmp/icu-git
cd /tmp/icu-git
git format-patch -1 <commit-hash> --stdout > /Users/michele.buccarello/distroless-the-hard-way/patches/icu/0001-<short-description>.patch
```

> This Atom builds from the `source/` subdirectory inside the extracted tarball (`LIB_SUBDIR=source` in `engine/config.yaml`). Make sure the patch's file paths are relative to `source/`, matching where `patch -p1` actually runs (`cd src/source` happens before the patch loop).

**Option B — no single commit, or you need to hand-edit**:

```bash
# edit the affected file(s) under /tmp/icu-patch-work/fixed/source/...
cd /tmp/icu-patch-work
diff -u orig/source/<file> fixed/source/<file> | \
  sed "s|orig/|a/|; s|fixed/|b/|" > /Users/michele.buccarello/distroless-the-hard-way/patches/icu/0001-<short-description>.patch
```

Either way, the resulting file must be a standard unified diff applicable with `patch -p1` **from the extracted tarball root** (i.e. path prefixes are `a/...` and `b/...`, one path component stripped).

## 4. Test the patch before committing

```bash
cd /Users/michele.buccarello/distroless-the-hard-way
python3 engine/engine.py --mode foundation
docker buildx bake -f foundations/foundations.hcl icu --progress=plain 2>&1 | grep -iE "Applying patch|error|FAILED"
```

Look for `Applying patch: /tmp/patches/icu/...` followed by the build continuing normally. If the patch does not apply cleanly, `patch -p1` exits non-zero and the whole build fails at that exact step — there is no silent skip (see [`patches/README.md`](../README.md)).

## 5. Before committing

- Name the file `000N-<short-description>.patch` (numbered if more than one patch is needed for `icu`).
- Note the CVE ID and the source commit/advisory in the commit message.
- Remember: patching without a version bump makes the compiled binary's internal version string diverge from what it actually contains — see the scanner-detection tradeoff in [`patches/README.md`](../README.md#the-tradeoff-this-reintroduces).
