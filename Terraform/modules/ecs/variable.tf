variable "ecs_cluster_name" {
  type = string
}

variable "ecs_cluster_setting" {
  type = string
}

variable "ecs_cluster_setting_value" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "vpc_id" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "ecr_repository_name" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "ecs_security_group_id" {
  type = string
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "container_port" {
  type    = number
  default = 3000
}
variable "target_group_arn" {
  type = string
}
variable "public_subnets" {
    type = list(string)
}

