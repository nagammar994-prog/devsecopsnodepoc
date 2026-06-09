const express = require("express");
const helmet = require("helmet");

const app = express();
const PORT = process.env.PORT || 3000;

// Remove Express fingerprint
app.disable("x-powered-by");

// Security headers
app.use(
  helmet({
    contentSecurityPolicy: false
  })
);

// Additional headers
app.use((req, res, next) => {
  res.setHeader(
    "Permissions-Policy",
    "camera=(), microphone=(), geolocation=()"
  );

  res.setHeader(
    "Cross-Origin-Embedder-Policy",
    "require-corp"
  );

  res.setHeader(
    "Cache-Control",
    "no-store"
  );

  next();
});

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
          <li>SAST - Semgrep</li>
          <li>IaC Scan - Checkov</li>
          <li>SCA + Container Scan - Trivy</li>
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
