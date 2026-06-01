resource "aws_codepipeline" "pipeline" {

  name     = var.pipeline_name
  role_arn = var.pipeline_role_arn

  artifact_store {

    location = var.artifact_bucket_name

    type = "S3"
  }

  ###################################
  # SOURCE
  ###################################

  stage {

    name = "Source"

    action {

      name             = "GitHub"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"

      output_artifacts = ["source_output"]

      configuration = {

        ConnectionArn    = var.codestar_connection_arn

        FullRepositoryId = var.github_repository_id

        BranchName       = var.github_branch
      }
    }
  }

  ###################################
  # BUILD + SECURITY
  ###################################

  stage {

    name = "Build"

    action {

      name            = "CodeBuild"

      category        = "Build"

      owner           = "AWS"

      provider        = "CodeBuild"

      version         = "1"

      input_artifacts = ["source_output"]

      output_artifacts = [
        "build_output"
      ]

      configuration = {

        ProjectName = var.codebuild_build_project_name
      }
    }
  }

  ###################################
  # DEPLOY DEV
  ###################################

  stage {

    name = "DeployDev"

    action {

      name            = "DeployToECS"

      category        = "Deploy"

      owner           = "AWS"

      provider        = "ECS"

      version         = "1"

      input_artifacts = ["build_output"]

      configuration = {

        ClusterName = var.ecs_cluster_name

        ServiceName = var.ecs_service_name

        FileName    = "imagedefinitions.json"
      }
    }
  }

  ###################################
  # DAST
  ###################################

  stage {

    name = "DAST"

    action {

      name            = "OWASP-ZAP"

      category        = "Build"

      owner           = "AWS"

      provider        = "CodeBuild"

      version         = "1"

      input_artifacts = ["build_output"]

      configuration = {

        ProjectName = var.codebuild_zap_project_name
      }
    }
  }

  ###################################
  # APPROVAL
  ###################################

#   stage {

#     name = "Approval"

#     action {

#       name     = "ManualApproval"

#       category = "Approval"

#       owner    = "AWS"

#       provider = "Manual"

#       version  = "1"
#     }
#   }

  ###################################
  # DEPLOY PROD
  ###################################

#   stage {

#     name = "DeployProd"

#     action {

#       name            = "DeployProd"

#       category        = "Deploy"

#       owner           = "AWS"

#       provider        = "ECS"

#       version         = "1"

#       input_artifacts = ["build_output"]

#       configuration = {

#         ClusterName = aws_ecs_cluster.cluster.name

#         ServiceName = aws_ecs_service.prod.name

#         FileName    = "imagedefinitions.json"
#       }
#     }
#   }
}