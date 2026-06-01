resource "aws_codebuild_project" "security_build" {

  name         = var.security_build_name
  service_role = var.codebuild_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "cicd/buildspec-security.yml"
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
    buildspec = "cicd/buildspec-zap.yml"
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