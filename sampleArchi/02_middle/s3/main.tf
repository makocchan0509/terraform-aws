variable bucket_name {
    default = "masem-alb-log-terraform"
}

resource "aws_s3_bucket" "alb_log" {
    bucket = var.bucket_name
    force_destroy = true

    lifecycle_rule {
      enabled = true

      expiration {
          days = "180"
      }
    }
}

resource "aws_s3_bucket_public_access_block" "private" {
    bucket = aws_s3_bucket.alb_log.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "alb_log" {
    bucket = aws_s3_bucket.alb_log.id
    policy = data.aws_iam_policy_document.alb_log.json
    depends_on = [aws_s3_bucket_public_access_block.private]
}

data "aws_iam_policy_document" "alb_log" {
    statement {
        effect = "Allow"
        actions = ["s3:PutObject"]
        resources = ["arn:aws:s3:::${aws_s3_bucket.alb_log.id}/*"]

        principals {
            type = "AWS"
            identifiers = ["582318560864"]
        }
    }
}

output "access_log_bucket_id" {
    value = aws_s3_bucket.alb_log.id
}