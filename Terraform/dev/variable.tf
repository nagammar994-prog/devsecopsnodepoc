# Global Variables
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "project_name" {
  type    = string
  default = "devsecops-poc"
}

variable "common_tags" {
  type = map(string)
  default = {
    Environment = "dev"
    Project     = "devsecops-poc"
    ManagedBy   = "Terraform"
  }
}

# VPC Variables
variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.11.0/24"]
}

# ALB Variables
variable "alb_name" {
  type    = string
  default = "devsecops-alb"
}

variable "alb_internal" {
  type    = bool
  default = false
}

# ECR Variables
variable "ecr_repository_name" {
  type    = string
  default = "devsecops-poc"
}

variable "scan_on_push" {
  type    = bool
  default = true
}

variable "image_tag_mutability" {
  type    = string
  default = "MUTABLE"
}

# ECS Variables
variable "ecs_cluster_name" {
  type    = string
  default = "devsecops-cluster"
}

variable "ecs_cluster_setting" {
  type    = string
  default = "containerInsights"
}

variable "ecs_cluster_setting_value" {
  type    = string
  default = "enabled"
}

# CloudWatch Variables
variable "log_group_name" {
  type    = string
  default = "/ecs/devsecops-poc"
}

variable "retention_in_days" {
  type    = number
  default = 7
}

# IAM Variables
variable "codebuild_role_name" {
  type    = string
  default = "devsecops-codebuild-role"
}

variable "codebuild_policy_name" {
  type    = string
  default = "devsecops-codebuild-policy"
}

variable "pipeline_role_name" {
  type    = string
  default = "devsecops-pipeline-role"
}

variable "pipeline_policy_name" {
  type    = string
  default = "devsecops-pipeline-policy"
}

variable "allow_ecr_resources" {
  type    = list(string)
  default = ["*"]
}

variable "allow_s3_resources" {
  type    = list(string)
  default = ["*"]
}

# CodeBuild Variables
variable "security_build_name" {
  type    = string
  default = "devsecops-security-build"
}

variable "zap_build_name" {
  type    = string
  default = "devsecops-zap-dast"
}

variable "compute_type" {
  type    = string
  default = "BUILD_GENERAL1_MEDIUM"
}

variable "docker_image" {
  type    = string
  default = "aws/codebuild/standard:7.0"
}

# CodePipeline Variables
variable "pipeline_name" {
  type    = string
  default = "devsecops-pipeline"
}

variable "artifact_bucket_name" {
  type    = string
  default = "devsecops-artifacts-dev"
}

variable "codestar_connection_arn" {
  type    = string
  default = "arn:aws:codeconnections:us-east-1:442391649779:connection/9da29dcb-2bf4-4ef5-891b-35d747630117"
}

variable "github_repository_id" {
  type    = string
  default = "your-github-user/devsecops-poc"
}

variable "github_branch" {
  type    = string
  default = "feature123"
}

variable "ecs_service_name" {
  type    = string
  default = "devsecops-app"
}

variable "codebuild_build_project_name" {
  type    = string
  default = "devsecops-build"
}

# Security Group Variables
variable "alb_security_group_name" {
  type    = string
  default = "devsecops-alb-sg"
}

variable "ecs_security_group_name" {
  type    = string
  default = "devsecops-ecs-sg"
}

variable "alb_ingress_port" {
  type    = number
  default = 80
}

variable "alb_ingress_cidr_blocks" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "ecs_ingress_port" {
  type    = number
  default = 3000
}
