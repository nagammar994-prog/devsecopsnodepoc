resource "aws_codebuild_project" "security_build" {

  name         = var.security_build_name
  service_role = var.codebuild_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = <<EOF
version: 0.2
resource "aws_codebuild_project" "security_build" {

  name         = var.security_build_name
  service_role = var.codebuild_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = <<EOF
version: 0.2

env:
  variables:
    IMAGE_REPO_NAME: devsecops-poc

phases:

  install:
    runtime-versions:
      resource "aws_codebuild_project" "security_build" {

        name         = var.security_build_name
        service_role = var.codebuild_role_arn

        artifacts {
          type = "CODEPIPELINE"
        }

        source {
          type      = "CODEPIPELINE"
          buildspec = <<EOF
      version: 0.2

      env:
        variables:
          IMAGE_REPO_NAME: devsecops-poc

      phases:

        install:
          runtime-versions:
            nodejs: 18

          commands:
            - echo "Installing tools"
            - pip3 install checkov
            - curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
            - curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh
            - curl -sL -o gitleaks.tar.gz https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks_8.24.2_linux_x64.tar.gz || (echo "gitleaks download failed" && exit 1)
            - tar -xzf gitleaks.tar.gz
            - chmod +x gitleaks

        pre_build:
          commands:
            - echo "ECR Login"
            - aws ecr get-login-password | docker login --username AWS --password-stdin $${AWS_ACCOUNT_ID}.dkr.ecr.$${AWS_DEFAULT_REGION}.amazonaws.com
            - IMAGE_TAG=$${CODEBUILD_BUILD_NUMBER}
            - IMAGE_URI=$${AWS_ACCOUNT_ID}.dkr.ecr.$${AWS_DEFAULT_REGION}.amazonaws.com/$${IMAGE_REPO_NAME}:$${IMAGE_TAG}
            - npm install

        build:
          commands:
            - echo "Secrets Scan"
            - ./gitleaks detect --source . --exit-code 1
            - echo "Dependency Scan"
            - npm audit --audit-level=high
            - echo "Docker Build"
            - docker build -t $${IMAGE_URI} ./app
            - echo "Trivy Scan"
            - ./bin/trivy image --exit-code 1 --severity HIGH,CRITICAL $${IMAGE_URI}
            - echo "Terraform Validation"
            - terraform -chdir=terraform init -backend=false
            - terraform -chdir=terraform validate
            - echo "Checkov"
            - checkov -d terraform
            - echo "tfsec"
            - tfsec terraform

        post_build:
          commands:
            - docker push $${IMAGE_URI}
            - echo "[{\"name\":\"devsecops-poc\",\"imageUri\":\"$${IMAGE_URI}\"}]" > imagedefinitions.json

      artifacts:
        files:
          - imagedefinitions.json
      EOF
        }

        environment {
          compute_type    = var.compute_type
          image           = var.docker_image
          type            = "LINUX_CONTAINER"
          privileged_mode = true

          environment_variable {
            name  = "AWS_DEFAULT_REGION"
            value = var.aws_region
          }

          environment_variable {
            name  = "AWS_ACCOUNT_ID"
            value = var.aws_account_id
          }
        }

        tags = var.tags
      }

      resource "aws_codebuild_project" "zap_dast" {

        name         = var.zap_build_name
        service_role = var.codebuild_role_arn

        artifacts {
          type = "CODEPIPELINE"
        }

        source {
          type      = "CODEPIPELINE"
          buildspec = <<EOF
      version: 0.2

      env:
        variables:
          TARGET_URL: "http://replace-with-alb-dns"

      phases:

        install:
          commands:
            - echo "Installing OWASP ZAP"
            - curl -sL -o zap.tar.gz https://github.com/zaproxy/zaproxy/releases/latest/download/ZAP_WEEKLY_D_linux.tar.gz || (echo "zap download failed" && exit 1)
            - tar -xzf zap.tar.gz

        build:
          commands:
            - echo "Running OWASP ZAP"
            - ./ZAP*/zap-baseline.py -t $${TARGET_URL} -r zap-report.html
            - |
              if grep -q "FAIL-NEW" zap-report.html; then
                echo "High severity findings detected"
                exit 1
              fi

      artifacts:
        files:
          - zap-report.html
      EOF
        }

        environment {
          compute_type    = var.compute_type
          image           = var.docker_image
          type            = "LINUX_CONTAINER"
          privileged_mode = false

          environment_variable {
            name  = "TARGET_URL"
            value = var.target_url
          }
        }

        tags = var.tags
      }