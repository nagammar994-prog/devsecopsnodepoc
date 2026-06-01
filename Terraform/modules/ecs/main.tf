resource "aws_ecs_cluster" "cluster" {
  name = var.ecs_cluster_name

  setting {
    name  = var.ecs_cluster_setting
    value = var.ecs_cluster_setting_value
  }

  tags = var.tags
}