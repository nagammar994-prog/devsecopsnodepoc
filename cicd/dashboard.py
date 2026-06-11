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
    except Exception as e:
        print(f"Unable to parse {path}: {e}")
        return None


def get_severity(value, default="LOW"):
    return str(value or default).upper()


# =====================================================
# SEMGREP
# =====================================================

semgrep = load_json(f"{REPORTS_DIR}/semgrep.json")

if semgrep:

    findings = semgrep.get("results", [])

    tool_counts["Semgrep"] = len(findings)

    for finding in findings:

        sev = get_severity(
            finding.get("extra", {}).get("severity"),
            "LOW"
        )

        if sev in severity_counts:
            severity_counts[sev] += 1
        else:
            severity_counts["LOW"] += 1


# =====================================================
# CHECKOV
# =====================================================

checkov = load_json(f"{REPORTS_DIR}/checkov.json")

if checkov:

    failed_checks = (
        checkov.get("results", {})
        .get("failed_checks", [])
    )

    tool_counts["Checkov"] = len(failed_checks)

    for finding in failed_checks:

        severity = finding.get("severity")

        # Newer Checkov versions sometimes return:
        # {"severity":{"level":"HIGH"}}

        if isinstance(severity, dict):
            severity = severity.get("level")

        sev = get_severity(
            severity,
            "MEDIUM"
        )

        if sev in severity_counts:
            severity_counts[sev] += 1
        else:
            severity_counts["MEDIUM"] += 1


# =====================================================
# TRIVY FILESYSTEM
# =====================================================

trivy_fs = load_json(
    f"{REPORTS_DIR}/trivy-fs.json"
)

if trivy_fs:

    for result in trivy_fs.get("Results", []):

        vulns = result.get(
            "Vulnerabilities",
            []
        ) or []

        tool_counts["Trivy FS"] += len(vulns)

        for vuln in vulns:

            sev = get_severity(
                vuln.get("Severity"),
                "LOW"
            )

            if sev in severity_counts:
                severity_counts[sev] += 1


# =====================================================
# TRIVY IMAGE
# =====================================================

trivy_image = load_json(
    f"{REPORTS_DIR}/trivy-image.json"
)

if trivy_image:

    for result in trivy_image.get("Results", []):

        vulns = result.get(
            "Vulnerabilities",
            []
        ) or []

        tool_counts["Trivy Image"] += len(vulns)

        for vuln in vulns:

            sev = get_severity(
                vuln.get("Severity"),
                "LOW"
            )

            if sev in severity_counts:
                severity_counts[sev] += 1


# =====================================================
# SECURITY SCORE
# =====================================================

score = max(
    0,
    100
    - (severity_counts["CRITICAL"] * 10)
    - (severity_counts["HIGH"] * 5)
    - (severity_counts["MEDIUM"] * 2)
    - (severity_counts["LOW"] * 1)
)


# =====================================================
# ACTION PLAN
# =====================================================

actions = []

if severity_counts["CRITICAL"] > 0:
    actions.append(
        "Fix all CRITICAL findings immediately."
    )

if severity_counts["HIGH"] > 0:
    actions.append(
        "Fix HIGH severity findings before production deployment."
    )

if severity_counts["MEDIUM"] > 0:
    actions.append(
        "Create backlog tasks for MEDIUM severity findings."
    )

if not actions:
    actions.append(
        "No significant findings detected."
    )


# =====================================================
# DEBUG OUTPUT
# =====================================================

print("Severity Counts:")
print(severity_counts)

print("Tool Counts:")
print(tool_counts)

print(f"Security Score: {score}")


# =====================================================
# HTML DASHBOARD
# =====================================================

html = f"""
<!DOCTYPE html>
<html>
<head>

<title>DevSecOps Security Dashboard</title>

<style>

body {{
    font-family: Arial, sans-serif;
    background:#f4f6f8;
    margin:30px;
}}

.card {{
    display:inline-block;
    width:220px;
    margin:10px;
    padding:20px;
    background:white;
    border-radius:10px;
    box-shadow:0 2px 8px rgba(0,0,0,.1);
}}

.big {{
    font-size:36px;
    font-weight:bold;
}}

table {{
    width:100%;
    border-collapse:collapse;
    background:white;
    margin-top:20px;
}}

th,td {{
    padding:12px;
    border:1px solid #ddd;
}}

th {{
    background:#f3f4f6;
}}

.section {{
    margin-top:30px;
}}

</style>

</head>

<body>

<h1>DevSecOps Security Dashboard</h1>

<div class="card">
<h3>Security Score</h3>
<div class="big">{score}</div>
</div>

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

<div class="section">
<h2>Findings By Tool</h2>

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
</div>

<div class="section">
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
