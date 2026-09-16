# Security Patches: `sqlite`

- **Pinned source (from `engine/config.yaml`)**: https://www.sqlite.org/2024/sqlite-autoconf-3470000.tar.gz
- **Upstream repository** (to locate/verify a fix commit): https://github.com/sqlite/sqlite (read-only mirror of the canonical Fossil repo at sqlite.org/src)
- **Security advisories**: [sqlite.org/cves.html](https://www.sqlite.org/cves.html) — dedicated, actively maintained.
- **Build config** (from `engine/config.yaml`, `packages.sqlite`): *(none — plain `./configure --prefix=/usr`)*


**Option A below does not work as written for this Atom.** The pinned tarball is the *amalgamation* build (`sqlite3.c` — one file combining the entire source tree, verified by inspecting the actual tarball contents), not the multi-file tree the `github.com/sqlite/sqlite` mirror has (`src/select.c`, `src/where.c`, etc.). A `git format-patch` generated from the mirror will reference paths that don't exist in the amalgamation and will not apply. Use Option B instead: find the fix commit for context, then locate the equivalent code inside `sqlite3.c` by function name and hand-edit it there.

Most historical SQLite CVEs also require the attacker to already control the SQL statements executed or the database file opened — read the advisory's applicability note before treating a finding as urgent.

## 1. Check whether a patch is actually needed

Prefer bumping the pinned version over patching — see the decision rule in [`patches/README.md`](../README.md). Check first:

```bash
python3 scripts/scan-sbom.py stacks/
```

If it flags `sqlite`, or you already have a specific CVE from the advisory page above, continue below.

## 2. Get the exact pinned source

```bash
mkdir -p /tmp/sqlite-patch-work && cd /tmp/sqlite-patch-work
curl -L "https://www.sqlite.org/2024/sqlite-autoconf-3470000.tar.gz" -o source.tar.gz
mkdir -p orig fixed
tar -xf source.tar.gz -C orig --strip-components=1
tar -xf source.tar.gz -C fixed --strip-components=1
```

## 3. Produce the fix

**Option A — you have the exact upstream commit that fixes the CVE** (fastest, least error-prone):

```bash
git clone --filter=blob:none https://github.com/sqlite/sqlite /tmp/sqlite-git
cd /tmp/sqlite-git
git format-patch -1 <commit-hash> --stdout > /Users/michele.buccarello/distroless-the-hard-way/patches/sqlite/0001-<short-description>.patch
```

**Option B — no single commit, or you need to hand-edit**:

```bash
# edit the affected file(s) under /tmp/sqlite-patch-work/fixed/...
cd /tmp/sqlite-patch-work
diff -u orig/<file> fixed/<file> | \
  sed "s|orig/|a/|; s|fixed/|b/|" > /Users/michele.buccarello/distroless-the-hard-way/patches/sqlite/0001-<short-description>.patch
```

Either way, the resulting file must be a standard unified diff applicable with `patch -p1` **from the extracted tarball root** (i.e. path prefixes are `a/...` and `b/...`, one path component stripped).

## 4. Test the patch before committing

```bash
cd /Users/michele.buccarello/distroless-the-hard-way
python3 engine/engine.py --mode foundation
docker buildx bake -f foundations/foundations.hcl sqlite --progress=plain 2>&1 | grep -iE "Applying patch|error|FAILED"
```

Look for `Applying patch: /tmp/patches/sqlite/...` followed by the build continuing normally. If the patch does not apply cleanly, `patch -p1` exits non-zero and the whole build fails at that exact step — there is no silent skip (see [`patches/README.md`](../README.md)).

## 5. Before committing

- Name the file `000N-<short-description>.patch` (numbered if more than one patch is needed for `sqlite`).
- Note the CVE ID and the source commit/advisory in the commit message.
- Remember: patching without a version bump makes the compiled binary's internal version string diverge from what it actually contains — see the scanner-detection tradeoff in [`patches/README.md`](../README.md#the-tradeoff-this-reintroduces).
