resource "aws_lb" "alb" {
  name               = var.alb_name
  internal           = var.alb_internal
  load_balancer_type = "application"

  security_groups = var.alb_security_group_ids
  subnets         = var.subnet_ids

  tags = var.tags
}