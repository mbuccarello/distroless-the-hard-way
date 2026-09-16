# Source Patches

This directory holds patches applied to upstream source tarballs before compilation. Use it only when no upstream release yet contains a fix — if a fixed release already exists, bump the pinned version in `engine/config.yaml` / `stacks/*.yaml` instead (see `docs/OPERATIONS.md` §1.2); that path always takes priority over patching.

## How to know a patch is needed

Same method for all 20 Atoms — there is no per-library monitoring step:

1. **Run `scripts/scan-sbom.py`** against the stack definitions. It reads the exact pinned name/version of every Atom directly from `stacks/*.yaml` and queries [OSV.dev](https://osv.dev) for each one — this is the project's own existing tool, already wired for this exact question:
   ```bash
   python3 scripts/scan-sbom.py stacks/
   ```
2. Or query [OSV.dev](https://osv.dev) or the [GitHub Advisory Database](https://github.com/advisories) directly by package name for a quicker manual check on a single Atom.

Both aggregate most of the per-project advisory sources in the table below, so they're the right first step even though the table exists — use the table once you already know *which* CVE you're chasing and need the actual fix (a specific commit, a specific patch file) rather than just a yes/no answer.

## Per-Atom security sources

Where to find the authoritative advisory and the source repository to diff against, for every Atom currently in `engine/config.yaml`. Maturity of upstream security process varies a lot across this list — some projects (OpenSSL, curl, SQLite, MIT krb5) publish a dedicated advisory page with one entry per CVE; most of the smaller C libraries have no such page and are only tracked through the generic trackers (GitHub Advisory Database, NVD, OSV) or, for GNU tools, the Savannah bug tracker.

| Atom | Source repo (diff against this) | Security advisories | Notes |
| :--- | :--- | :--- | :--- |
| `zlib` | [github.com/madler/zlib](https://github.com/madler/zlib) | No dedicated page — [OSV.dev](https://osv.dev/list?ecosystem=&q=zlib), [GitHub Advisory DB](https://github.com/advisories?query=zlib) | |
| `openssl` | [github.com/openssl/openssl](https://github.com/openssl/openssl) | [openssl-library.org/news/vulnerabilities](https://openssl-library.org/news/vulnerabilities/) | Best-maintained advisory page in this list — one entry per CVE with affected/fixed versions. |
| `ncurses` | [git.savannah.gnu.org/git/ncurses.git](https://git.savannah.gnu.org/git/ncurses.git) | No dedicated page — [Savannah bug tracker](https://savannah.gnu.org/bugs/?group=ncurses), OSV.dev | |
| `readline` | [git.savannah.gnu.org/git/readline.git](https://git.savannah.gnu.org/git/readline.git) | No dedicated page — Savannah bug tracker, OSV.dev | |
| `sqlite` | [sqlite.org](https://www.sqlite.org/src) (read-only GitHub mirror: [sqlite/sqlite](https://github.com/sqlite/sqlite)) | [sqlite.org/cves.html](https://www.sqlite.org/cves.html) | Dedicated, actively maintained page. |
| `libxcrypt` | [github.com/besser82/libxcrypt](https://github.com/besser82/libxcrypt) | No dedicated page — GitHub Advisory DB, OSV.dev, project's own `NEWS` file | |
| `libffi` | [github.com/libffi/libffi](https://github.com/libffi/libffi) | No dedicated page — GitHub Advisory DB, OSV.dev | |
| `expat` | [github.com/libexpat/libexpat](https://github.com/libexpat/libexpat) | [libexpat.github.io/doc](https://libexpat.github.io/doc/xml-security/) | Publishes an individual page per CVE (`libexpat.github.io/doc/cve-YYYY-NNNNN/`). |
| `bzip2` | [sourceware.org/git/bzip2.git](https://sourceware.org/git/?p=bzip2.git) | No dedicated page — GitHub Advisory DB, OSV.dev | |
| `xz` | [github.com/tukaani-project/xz](https://github.com/tukaani-project/xz) | No dedicated page — GitHub Advisory DB, OSV.dev, distro trackers | This is the package behind the [CVE-2024-3094 backdoor](https://www.cisa.gov/news-events/alerts/2024/03/29/reported-supply-chain-compromise-affecting-xz-utils-data-compression-library-cve-2024-3094) — verify tarball checksums with extra care before pinning a new version here. |
| `gdbm` | [git.savannah.gnu.org/git/gdbm.git](https://git.savannah.gnu.org/git/gdbm.git) | No dedicated page — Savannah bug tracker, OSV.dev | |
| `icu` | [github.com/unicode-org/icu](https://github.com/unicode-org/icu) | No dedicated page — GitHub Advisory DB, OSV.dev | Installed via `dnf install libicu-devel` in this project (see the `icu` special case in `engine.py`), not compiled from the tarball — a `patches/icu/` directory would currently be ignored, since there's no `./configure && make` step for this Atom to patch before. |
| `brotli` | [github.com/google/brotli](https://github.com/google/brotli) | [github.com/google/brotli/security/advisories](https://github.com/google/brotli/security/advisories) | |
| `c-ares` | [github.com/c-ares/c-ares](https://github.com/c-ares/c-ares) | [github.com/c-ares/c-ares/security/advisories](https://github.com/c-ares/c-ares/security/advisories) | |
| `nghttp2` | [github.com/nghttp2/nghttp2](https://github.com/nghttp2/nghttp2) | [github.com/nghttp2/nghttp2/security/advisories](https://github.com/nghttp2/nghttp2/security/advisories) | Security process documented at [nghttp2.org/documentation/security.html](https://nghttp2.org/documentation/security.html). |
| `krb5` | [github.com/krb5/krb5](https://github.com/krb5/krb5) (mirror; release tarballs are canonical from `web.mit.edu/kerberos`) | [web.mit.edu/kerberos/advisories](https://web.mit.edu/kerberos/advisories/) | Dedicated `MITKRB5-SA-YYYY-NNN` advisories, well maintained. |
| `libxml2` | [gitlab.gnome.org/GNOME/libxml2](https://gitlab.gnome.org/GNOME/libxml2) | No single dedicated page — GNOME/GitLab issue tracker, [GitHub Advisory DB](https://github.com/advisories?query=libxml2) | |
| `oniguruma` | [github.com/kkos/oniguruma](https://github.com/kkos/oniguruma) | No dedicated page — GitHub Advisory DB, OSV.dev | |
| `curl` | [github.com/curl/curl](https://github.com/curl/curl) | [curl.se/docs/vulnerabilities.html](https://curl.se/docs/vulnerabilities.html) | One of the best-maintained lists here — a version-by-version vulnerability table plus a dedicated page per CVE (`curl.se/docs/CVE-YYYY-NNNNN.html`). |
| `pcre2` | [github.com/PCRE2Project/pcre2](https://github.com/PCRE2Project/pcre2) | [github.com/PCRE2Project/pcre2/security](https://github.com/PCRE2Project/pcre2/security) | Security policy at [pcre2project.github.io/pcre2/project/security](https://pcre2project.github.io/pcre2/project/security/). |

Every Atom also has its own step-by-step guide at `patches/<name>/README.md` (e.g. [`patches/openssl/README.md`](openssl/README.md)) with copy-pasteable commands for that specific package: fetching the exact pinned tarball, generating the patch from an upstream commit or by hand, its `LIB_SUBDIR`/`config` quirks if any, and how to test it locally before committing.

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
