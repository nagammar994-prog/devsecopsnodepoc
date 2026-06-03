# VPC Module
module "vpc" {
  source = "../modules/vpc"

  vpc_cidr_block       = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = data.aws_availability_zones.available.names

  tags = var.common_tags
}

# Security Groups Module
module "security_groups" {
  source = "../modules/security_groups"

  vpc_id                  = module.vpc.vpc_id
  alb_security_group_name = var.alb_security_group_name
  ecs_security_group_name = var.ecs_security_group_name
  alb_ingress_port        = var.alb_ingress_port
  alb_ingress_cidr_blocks = var.alb_ingress_cidr_blocks
  ecs_ingress_port        = var.ecs_ingress_port

  tags = var.common_tags
}

# ALB Module
module "alb" {
  source = "../modules/alb"

  alb_name               = var.alb_name
  alb_internal           = var.alb_internal
  alb_security_group_ids = [module.security_groups.alb_security_group_id]
  subnet_ids             = module.vpc.public_subnet_ids
  vpc_id                 = module.vpc.vpc_id
  container_port         = var.container_port
  listener_port          = var.alb_ingress_port

  tags = var.common_tags
}

# S3 Artifact Bucket
resource "aws_s3_bucket" "artifacts" {
  bucket = var.artifact_bucket_name

  tags = var.common_tags
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ECR Module
module "ecr" {
  source = "../modules/ecr"

  ecr_repository_name  = var.ecr_repository_name
  scan_on_push         = var.scan_on_push
  image_tag_mutability = var.image_tag_mutability

  tags = var.common_tags
}

# ECS Module
module "ecs" {
  source = "../modules/ecs"

  ecs_cluster_name          = var.ecs_cluster_name
  ecs_cluster_setting       = var.ecs_cluster_setting
  ecs_cluster_setting_value = var.ecs_cluster_setting_value
  vpc_id                    = module.vpc.vpc_id
  aws_account_id            = data.aws_caller_identity.current.account_id
  aws_region                = var.aws_region
  ecr_repository_name       = var.ecr_repository_name
  private_subnet_ids        = module.vpc.private_subnet_ids
  public_subnets            = module.vpc.public_subnet_ids
  ecs_security_group_id     = module.security_groups.ecs_security_group_id
  desired_count             = var.desired_count
  container_port            = var.container_port
  target_group_arn          = module.alb.target_group_arn

  tags = var.common_tags
}

# CloudWatch Module
module "cloudwatch" {
  source = "../modules/cloudwatch"

  log_group_name    = var.log_group_name
  retention_in_days = var.retention_in_days

  tags = var.common_tags
}

# IAM Module
module "iam" {
  source = "../modules/iam"

  environment           = var.environment
  codebuild_role_name   = var.codebuild_role_name
  codebuild_policy_name = var.codebuild_policy_name
  pipeline_role_name    = var.pipeline_role_name
  pipeline_policy_name  = var.pipeline_policy_name
  allow_ecr_resources   = var.allow_ecr_resources
  allow_s3_resources    = var.allow_s3_resources

  tags = var.common_tags
}

# CodeBuild Module
module "codebuild" {
  source = "../modules/codebuild"

  security_build_name = var.security_build_name
  zap_build_name      = var.zap_build_name
  codebuild_role_arn  = module.iam.codebuild_role_arn
  compute_type        = var.compute_type
  docker_image        = var.docker_image
  aws_region          = var.aws_region
  aws_account_id      = data.aws_caller_identity.current.account_id
  target_url          = module.alb.alb_dns_name

  tags = var.common_tags
}

# CodePipeline Module
module "codepipeline" {
  source = "../modules/codepipeline"

  pipeline_name                   = var.pipeline_name
  pipeline_role_arn               = module.iam.pipeline_role_arn
  artifact_bucket_name            = aws_s3_bucket.artifacts.id
  codestar_connection_arn         = var.codestar_connection_arn != "" ? var.codestar_connection_arn : "arn:aws:codestar-connections:us-east-1:${data.aws_caller_identity.current.account_id}:connection/github-placeholder"
  github_repository_id            = var.github_repository_id
  github_branch                   = var.github_branch
  ecs_cluster_name                = module.ecs.ecs_cluster_name
  ecs_service_name                = var.ecs_service_name
  codebuild_security_project_name = module.codebuild.security_build_name
  codebuild_build_project_name    = module.codebuild.security_build_name
  codebuild_zap_project_name      = module.codebuild.zap_build_name

  tags = var.common_tags

  depends_on = [aws_s3_bucket.artifacts]
}
