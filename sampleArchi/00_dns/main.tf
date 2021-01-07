
variable "hostzone_name" {
    default = "masemfordev.com"
}

resource "aws_route53_zone" "test_zone" {
    name = var.hostzone_name
}

## ACM
module "create_cert" {
    source = "./acm"
    domain_name = "*.masemfordev.com"
    zone_id = aws_route53_zone.test_zone.zone_id
}
