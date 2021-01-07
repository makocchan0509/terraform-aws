variable name {}
variable value {}
variable type {}
variable description {}

resource "aws_ssm_parameter" "parameter" {
    name = var.name
    value = var.value
    type = var.type
    description = var.description
}