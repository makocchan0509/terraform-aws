## The template will create clw log group.

variable "name" {
    default = "/ecs/terraform"
}

resource "aws_cloudwatch_log_group" "for_ecs" {
    name = var.name
    retention_in_days = 180
}