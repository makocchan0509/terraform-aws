variable "roleName" {}
variable "policyName" {}
variable "policy" {}
variable "identifier" {}

resource "aws_iam_policy" "policy" {
    name = var.policyName
    policy = var.policy
}

data "aws_iam_policy_document" "assume_role" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
          type = "Service"
          identifiers = [var.identifier]
        }
    }
}

resource "aws_iam_role" "role" {
    name = var.roleName
    assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "attach_policy_role" {
    role = aws_iam_role.role.name
    policy_arn = aws_iam_policy.policy.arn
}

output "iam_role_arn" {
    value = aws_iam_role.role.arn
}

output "iam_role_name" {
    value = aws_iam_role.role.name
}