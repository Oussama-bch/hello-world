
variable "s3_name_prefix" {
  type = string
}

variable "aws_region" {
  type = string
  default = "eu-west-3"
}

variable "container_port" {
  type = number
}


variable "ecs_type" {
  type = string
  default = "FARGATE"
}


variable "container_tag" {
  type = string
}

variable "container_conf" {
  description = "Container runtime configuration"
  type = object({
    tag    = string,
    port   = number,
    memory = number,
    cpu    = number,
    health_check = string,
    protocol =string
  })
}

variable "email" {
  type = string
  
}

variable "rds_username" {
}
variable "rds_password" {
}