# 🛡️ Security Validation Overview

This section contains automated reports generated directly during our continuous integration and delivery pipeline. We employ a defense-in-depth auditing strategy covering both vulnerability surface scanning and technical compliance benchmarks.

---

## 🔍 Validation Layers

Our security controls are divided into two distinct technical layers:

### 1. Vulnerability Surface Scanning (Trivy)
We continuously evaluate the container's file system for known security flaws (CVEs). Since we purge system managers like APT and DPKG, our software inventory remains incredibly small, resulting in a minimal attack surface.
*   [View Detailed Trivy Report](./trivy.md)

### 2. Standard Configuration Auditing (OpenSCAP)
We audit the file system against the **ANSSI-BP-028 (minimal)** profile to verify standard file permissions, group/user ownerships of login files, and overall system hardening.
*   [View Detailed OpenSCAP Report](./openscap.md)

---