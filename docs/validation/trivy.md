# 🔍 Vulnerability & SBOM Audit (Trivy)

**Target Image:** `debian-openssl-fips:latest`  
**Audit Strategy:** Zero-CVE Enforcement Policy

---

##  Vulnerability Scorecard

<div class="grid cards" markdown>

-   :material-lightning-bolt: **Critical**
    ---
    <span style="font-size: 2.2em; font-weight: bold; color: {% if trivy_stats.critical > 0 %}#d50000{% else %}#00c853{% endif %};">
      {{ trivy_stats.critical }}
    </span>

-   :material-alert: **High**
    ---
    <span style="font-size: 2.2em; font-weight: bold; color: {% if trivy_stats.high > 0 %}#ffab00{% else %}#00c853{% endif %};">
      {{ trivy_stats.high }}
    </span>

-   :material-alert-circle-outline: **Medium / Low**
    ---
    <span style="font-size: 2.2em; font-weight: bold; color: #424242;">
      {{ trivy_stats.medium + trivy_stats.low }}
    </span>

</div>

---

##  Active Vulnerability Log

{% if vulnerabilities | length == 0 %}
!!! success "Zero Vulnerabilities Confirmed :material-check-decagram:"
    The image is currently 100% clean and contains no known security vulnerabilities.
{% else %}
| Severity | CVE ID | Affected Package | Installed | Fixed Version | Title |
| :---: | :--- | :--- | :--- | :--- | :--- |
{% for v in vulnerabilities -%}
| {% if v.severity == 'CRITICAL' %}:material-lightning-bolt:{ .md-typeset__error }{% elif v.severity == 'HIGH' %}:material-alert:{ style="color: #ffab00" }{% else %}:material-alert-circle:{ style="color: #424242" }{% endif %} | [`{{ v.id }}`]({{ v.url }}) | `{{ v.package }}` | `{{ v.installed_version }}` | `{{ v.fixed_version | default('N/A') }}` | {{ v.title }} |
{% endfor %}
{% endif %}

---

## 📦 Software Bill of Materials (SBOM)

This inventory lists all operating system components currently installed in the final image layer:

| Package Name | Version | License |
| :--- | :--- | :--- |
{% for p in packages -%}
| **`{{ p.name }}`** | `{{ p.version }}` | `{{ p.license }}`