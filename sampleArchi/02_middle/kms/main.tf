variable alias_name {}

resource "aws_kms_key" "terraform-key" {
    description = "Managed by terraform"
    enable_key_rotation = true
    is_enabled = true
    deletion_window_in_days = 30
}

resource "aws_kms_alias" "terraform-key"{
    name = var.alias_name
    target_key_id = aws_kms_key.terraform-key.key_id
}