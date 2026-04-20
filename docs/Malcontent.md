# Specification: Binary Capability Analysis

The integrity of compiled OCI images is verified using Chainguard Malcontent to detect unexpected capabilities, syscalls, or malicious indicators.

---

## 1. Security Logic
Malcontent provides a rule-based inspection of binary artifacts. The system uses this tool as a final gate to ensure that the Total Isolation build strategy has not been bypassed by unexpected build-time behaviors.

## 2. Integration
Capability analysis is performed on the finalized Stage 3 (Base) and Product images before they are marked as ready for distribution.

