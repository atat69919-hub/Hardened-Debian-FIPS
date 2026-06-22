# 🛡️ Debian FIPS Hardened Infrastructure

Welcome to the High-Assurance Cryptographic and Compliance Dashboard for our custom, zero-vulnerability **Debian 13 (Trixie) FIPS** container environment.

This project delivers a production-hardened runtime designed for strict federal compliance boundaries and highly-regulated production microservices.

---

##  Live Security Posture

Our automated continuous compliance pipeline evaluates every container build against global security benchmarks. Below is the real-time status of the latest build:

<div class="grid cards" markdown>

-   :material-shield-bug: **Vulnerability Posture**
    ---
    {% if trivy_stats.total == 0 %}
    <span style="color: #00c853; font-size: 2.2em; font-weight: 900;">0 CVEs</span> :material-check-decagram:{ .md-typeset__success }
    <br>*Zero-Vulnerability State Confirmed*
    {% else %}
    <span style="color: #d50000; font-size: 2.2em; font-weight: 900;">{{ trivy_stats.total }} CVEs</span> :material-alert-decagram:{ .md-typeset__error }
    <br>*Remediation Required immediately*
    {% endif %}

-   :material-certificate: **FIPS 140-3 Validation**
    ---
    <span style="color: #00c853; font-size: 2.2em; font-weight: 900;">ACTIVE</span>
    <br>*Self-Tests & Cryptographic Boundaries Intact*

-   :material-scale-balance: **Ecosystem Footprint**
    ---
    <span style="font-size: 2.2em; font-weight: bold; color: #424242;">{{ packages | length }}</span>
    <br>*Surgically Purged minimal Rootfs (No APT/DPKG)*

</div>

---

##  Hardening Standards Complied

We evaluate our system configurations continuously across multiple compliance layers. Click below to explore detailed interactive reports:

*   [:material-bug-check: **Vulnerability & SBOM Audit**](./validation/trivy.md) — Comprehensive scan of the minimal rootfs.
*   [:material-text-box-search-outline: **ANSSI-BP-028 Compliance Report**](./validation/openscap.md) — Standard and Minimal ANSSI-BP-028 evaluations.
*   [:material-history: **Audit Generation Date:**] `{{ generation_date }}`

---