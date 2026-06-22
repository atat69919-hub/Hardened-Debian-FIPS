import json
import os
from datetime import datetime

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))

def load_json(path):
    if not os.path.exists(path):
        return {}
    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    except:
        return {}

def define_env(env):
    reports_dir = os.path.join(ROOT_DIR, "reports")
    trivy_report_path = os.path.join(reports_dir, "trivy-results.json")
    
    trivy_data = load_json(trivy_report_path)
    
    vulns_list = []
    packages_list = []
    stats = {"critical": 0, "high": 0, "medium": 0, "low": 0, "total": 0}
    
    if "Results" in trivy_data:
        for result in trivy_data["Results"]:
            if "Packages" in result:
                for pkg in result["Packages"]:
                    packages_list.append({
                        "name": pkg.get("Name", "N/A"),
                        "version": pkg.get("Version", "N/A"),
                        "license": pkg.get("Licenses", ["N/A"])[0] if isinstance(pkg.get("Licenses"), list) else pkg.get("Licenses", "N/A")
                    })
            if "Vulnerabilities" in result:
                for vuln in result["Vulnerabilities"]:
                    severity = vuln.get("Severity", "UNKNOWN").upper()
                    if severity == "CRITICAL":
                        stats["critical"] += 1
                    elif severity == "HIGH":
                        stats["high"] += 1
                    elif severity == "MEDIUM":
                        stats["medium"] += 1
                    elif severity == "LOW":
                        stats["low"] += 1
                    stats["total"] += 1
                    
                    vulns_list.append({
                        "id": vuln.get("VulnerabilityID", "N/A"),
                        "package": vuln.get("PkgName", "N/A"),
                        "severity": severity,
                        "installed_version": vuln.get("InstalledVersion", "N/A"),
                        "fixed_version": vuln.get("FixedVersion", "N/A"),
                        "title": vuln.get("Title", "N/A"),
                        "url": vuln.get("PrimaryURL", "#")
                    })
                    
    env.variables.update({
        "trivy_stats": stats,
        "vulnerabilities": vulns_list,
        "packages": packages_list,
        "generation_date": datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC")
    })