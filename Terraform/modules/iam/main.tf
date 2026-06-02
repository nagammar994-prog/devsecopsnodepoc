resource "aws_iam_role" "codebuild_role" {
  name = var.codebuild_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}
resource "aws_iam_role_policy" "codebuild_policy" {
  name = var.codebuild_policy_name
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },

      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = var.allow_ecr_resources
      },

      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:RegisterTaskDefinition"
        ]
        Resource = "*"
      },

      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectVersion"
        ]
        Resource = var.allow_s3_resources
      },

      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:BatchGetReports",
          "codebuild:CreateReport",
          "codebuild:UpdateReport"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "pipeline_role" {

  name = var.pipeline_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "codepipeline.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}
resource "aws_iam_role_policy" "pipeline_policy" {

  name = var.pipeline_policy_name
  role = aws_iam_role.pipeline_role.id

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning"
        ]

        Resource = var.allow_s3_resources
      },

      {
        Effect = "Allow"

        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:BatchGetReports",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:StartBuild"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:ListTasks"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "codestar-connections:UseConnection"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "pipeline_passrole_policy" {
  name = "${var.pipeline_policy_name}-passrole"
  role = aws_iam_role.pipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = aws_iam_role.codebuild_role.arn
      }
    ]
  })
}