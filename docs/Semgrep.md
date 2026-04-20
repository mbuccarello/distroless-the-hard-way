# Specification: Static Application Security Testing (SAST)

All source code ingested into the Distroless The Hard Way pipeline is audited via Semgrep before compilation.

---

## 1. Audit Strategy
The system utilizes the `p/c` and `p/security-audit` rulesets to detect:
- Memory safety vulnerabilities (buffer overflows, use-after-free).
- Insecure usage of library APIs.
- Potential backdoors or logic flaws in upstream archives.

## 2. Thresholds
The pipeline is configured to fail if high-severity vulnerabilities are detected without a pre-approved and documented security patch.

