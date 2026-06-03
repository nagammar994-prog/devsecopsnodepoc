variable "alb_name" {
  type = string
}

variable "alb_internal" {
  type    = bool
  default = false
}

variable "alb_security_group_ids" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "container_port" {
  type    = number
  default = 3000
}

variable "listener_port" {
  type    = number
  default = 80
}

variable "tags" {
  type = map(string)
}
