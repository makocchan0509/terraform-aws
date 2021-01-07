variable "domain_name" {}
variable "zone_id" {}

resource "aws_acm_certificate" "test_cert" {
    domain_name = var.domain_name
    subject_alternative_names = []
    validation_method = "DNS"

   lifecycle {
        create_before_destroy = true
    }
}

resource "aws_route53_record" "validate_record" {
    name = tolist(aws_acm_certificate.test_cert.domain_validation_options).0.resource_record_name
    type = tolist(aws_acm_certificate.test_cert.domain_validation_options).0.resource_record_type
    records = [tolist(aws_acm_certificate.test_cert.domain_validation_options).0.resource_record_value]
    zone_id = var.zone_id
    ttl = 60
}

resource "aws_acm_certificate_validation" "wait_validate" {
    certificate_arn = aws_acm_certificate.test_cert.arn
    validation_record_fqdns = [aws_route53_record.validate_record.fqdn]
}

output "acm_arn" {
    value = aws_acm_certificate.test_cert.arn
}