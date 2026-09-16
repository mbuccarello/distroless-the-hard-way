# Source Patches

This directory holds patches applied to upstream source tarballs before compilation. Use it only when no upstream release yet contains a fix — if a fixed release already exists, bump the pinned version in `engine/config.yaml` / `stacks/*.yaml` instead (see `docs/OPERATIONS.md` §1.2); that path always takes priority over patching.

## Layout

```
patches/
  <atom-or-runtime-name>/
    0001-short-description.patch
    0002-another-fix.patch
```

`<atom-or-runtime-name>` must match the package name exactly as it appears in `engine/config.yaml`'s `sources`/`packages` sections (for C library Atoms, e.g. `zlib`, `openssl`) or a runtime's `name` field in `stacks/*.yaml` (for source-built runtimes, e.g. `php`, `perl`). The build engine only looks for patches in a directory matching that exact name.

Patches are applied in filename sort order, so prefix them `0001-`, `0002-`, etc. if more than one is needed for the same package.

## Format

Standard unified diff (`diff -u`), applied with `patch -p1` from the extracted source root — the same format `git diff`/`git format-patch` produce. Generate one against the exact pinned version's tarball:

```bash
curl -L "<sources url from config.yaml>" -o source.tar.gz
mkdir orig fixed && tar -xf source.tar.gz -C orig --strip-components=1 && tar -xf source.tar.gz -C fixed --strip-components=1
# edit files under fixed/ ...
diff -u orig/<file> fixed/<file> | sed "s|orig/|a/|; s|fixed/|b/|" > patches/<name>/0001-description.patch
```

## What happens if a patch doesn't apply

`engine.py` emits a build step that applies every `*.patch` file in the matching directory with `patch -p1` before `./configure`/`make` runs. If a patch fails to apply cleanly, `patch` exits non-zero and the build fails loudly at that step — there is no silent skip.

## The tradeoff this reintroduces

Patching without bumping the version means the compiled binary's internal version string no longer matches what it actually contains. Any scanner that fingerprints binaries by that string (see `docs/SCANNER_PARADOX.md` §3.3–§4.3) will flag the CVE you just fixed as a false positive, because it has no way to know a patch was applied out of band. This project does not currently publish an OpenVEX document to suppress that — if you patch a package here, expect (and document) that mismatch until VEX generation exists (`docs/SCANNER_PARADOX.md` §7.5).
