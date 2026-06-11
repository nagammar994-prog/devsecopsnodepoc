import json
import os

REPORTS_DIR = "reports"

severity_counts = {
    "CRITICAL": 0,
    "HIGH": 0,
    "MEDIUM": 0,
    "LOW": 0
}

tool_counts = {
    "Semgrep": 0,
    "Checkov": 0,
    "Trivy FS": 0,
    "Trivy Image": 0
}


def load_json(path):
    if not os.path.exists(path):
        return None

    try:
        with open(path, "r") as f:
            return json.load(f)
    except Exception:
        return None


# ---------------------------
# Semgrep
# ---------------------------

semgrep = load_json(f"{REPORTS_DIR}/semgrep.json")

if semgrep:
    findings = semgrep.get("results", [])
    tool_counts["Semgrep"] = len(findings)

    for finding in findings:
        sev = (
            finding.get("extra", {})
            .get("severity", "LOW")
            .upper()
        )

        if sev in severity_counts:
            severity_counts[sev] += 1


# ---------------------------
# Checkov
# ---------------------------

checkov = load_json(f"{REPORTS_DIR}/checkov.json")

if checkov:

    failed_checks = (
        checkov.get("results", {})
        .get("failed_checks", [])
    )

    tool_counts["Checkov"] = len(failed_checks)

    for finding in failed_checks:

        sev = (
            finding.get("severity", "MEDIUM")
            .upper()
        )

        if sev in severity_counts:
            severity_counts[sev] += 1
        else:
            severity_counts["MEDIUM"] += 1


# ---------------------------
# Trivy Filesystem
# ---------------------------

trivy_fs = load_json(f"{REPORTS_DIR}/trivy-fs.json")

if trivy_fs:

    for result in trivy_fs.get("Results", []):

        vulns = result.get("Vulnerabilities", [])

        tool_counts["Trivy FS"] += len(vulns)

        for vuln in vulns:

            sev = vuln.get("Severity", "LOW")

            if sev in severity_counts:
                severity_counts[sev] += 1


# ---------------------------
# Trivy Image
# ---------------------------

trivy_img = load_json(f"{REPORTS_DIR}/trivy-image.json")

if trivy_img:

    for result in trivy_img.get("Results", []):

        vulns = result.get("Vulnerabilities", [])

        tool_counts["Trivy Image"] += len(vulns)

        for vuln in vulns:

            sev = vuln.get("Severity", "LOW")

            if sev in severity_counts:
                severity_counts[sev] += 1


# ---------------------------
# Action Plan
# ---------------------------

actions = []

if severity_counts["CRITICAL"] > 0:
    actions.append(
        "Fix all CRITICAL findings immediately."
    )

if severity_counts["HIGH"] > 0:
    actions.append(
        "Remediate HIGH severity findings before release."
    )

if severity_counts["MEDIUM"] > 0:
    actions.append(
        "Review MEDIUM findings and create backlog items."
    )

if not actions:
    actions.append(
        "No significant security findings detected."
    )


# ---------------------------
# Generate HTML
# ---------------------------

html = f"""
<!DOCTYPE html>
<html>
<head>
<title>DevSecOps Security Dashboard</title>

<style>

body {{
    font-family: Arial, sans-serif;
    background: #f4f6f8;
    margin: 20px;
}}

h1 {{
    color: #1f2937;
}}

.cards {{
    display:flex;
    gap:20px;
    flex-wrap:wrap;
}}

.card {{
    background:white;
    border-radius:10px;
    padding:20px;
    width:220px;
    box-shadow:0 2px 8px rgba(0,0,0,.1);
}}

.big {{
    font-size:32px;
    font-weight:bold;
}}

table {{
    width:100%;
    border-collapse:collapse;
    margin-top:20px;
    background:white;
}}

th, td {{
    padding:12px;
    border:1px solid #ddd;
}}

th {{
    background:#f3f4f6;
}}

.action {{
    background:white;
    padding:20px;
    margin-top:20px;
    border-radius:10px;
}}

</style>
</head>

<body>

<h1>DevSecOps Security Dashboard</h1>

<div class="cards">

<div class="card">
<h3>Critical</h3>
<div class="big">{severity_counts["CRITICAL"]}</div>
</div>

<div class="card">
<h3>High</h3>
<div class="big">{severity_counts["HIGH"]}</div>
</div>

<div class="card">
<h3>Medium</h3>
<div class="big">{severity_counts["MEDIUM"]}</div>
</div>

<div class="card">
<h3>Low</h3>
<div class="big">{severity_counts["LOW"]}</div>
</div>

</div>

<h2>Tool Findings</h2>

<table>
<tr>
<th>Tool</th>
<th>Findings</th>
</tr>

<tr>
<td>Semgrep</td>
<td>{tool_counts["Semgrep"]}</td>
</tr>

<tr>
<td>Checkov</td>
<td>{tool_counts["Checkov"]}</td>
</tr>

<tr>
<td>Trivy FS</td>
<td>{tool_counts["Trivy FS"]}</td>
</tr>

<tr>
<td>Trivy Image</td>
<td>{tool_counts["Trivy Image"]}</td>
</tr>

</table>

<div class="action">

<h2>Recommended Action Plan</h2>

<ul>
{''.join([f'<li>{a}</li>' for a in actions])}
</ul>

</div>

</body>
</html>
"""

with open(
    f"{REPORTS_DIR}/security-dashboard.html",
    "w"
) as f:
    f.write(html)

print("Dashboard generated successfully.")
