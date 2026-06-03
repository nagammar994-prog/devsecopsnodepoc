const express = require("express");

const app = express();
const PORT = process.env.PORT || 3000;

app.get("/", (req, res) => {
  res.send(`
    <html>
      <head>
        <title>DevSecOps POC</title>
      </head>
      <body>
        <h1>DevSecOps POC</h1>

        <h2>Security Pipeline</h2>
        <ul>
          <li>SAST - Gitleaks</li>
          <li>IaC Scan - Checkov</li>
          <li>Terraform Scan - tfsec</li>
          <li>SCA - npm audit</li>
          <li>Container Scan - Trivy</li>
          <li>ECR Scan-on-Push</li>
          <li>DAST - OWASP ZAP</li>
        </ul>

        <p>Application deployed on ECS Fargate behind an Application Load Balancer.</p>
      </body>
    </html>
  `);
});

app.get("/health", (req, res) => {
  res.status(200).json({
    status: "UP"
  });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});