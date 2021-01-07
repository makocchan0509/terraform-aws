variable vpc_id {}
variable lb_name {
    default = "terraform"
}
variable access_log_bucket {
    default = "masem-alb-log-terraform"
}
variable load_balancer_type {
    default = "application"
}
variable hostzone_name {
    default = "masemfordev.com"
}
variable record_name {
    default = "terraform.masemfordev.com"
}
variable acm_domain {
    default = "*.elb.amazonaws.com"
}
variable lb_subnets {
    type = list(string)
}

## Get Route53 record
#data "aws_route53_zone" "hostzone" {
#    name = var.hostzone_name
#}

## Route53 record for ELB
#resource "aws_route53_record" "test_record" {
#    zone_id = data.aws_route53_zone.hostzone.zone_id
#    name = var.record_name
#    type = "A"
#
#    alias {
#        name = var.lb_dns_name
#        zone_id = var.lb_zone_id
#        evaluate_target_health = true
#    }
#}

## Security Group http
module "http_sg" {
    source = "../sg"
    name = "http_sg"
    vpc_id = var.vpc_id
    port = 80
    cidr_blocks = ["0.0.0.0/0"]
}

## Security Group https
module "https_sg" {
    source = "../sg"
    name = "https_sg"
    vpc_id = var.vpc_id
    port = 443
    cidr_blocks = ["0.0.0.0/0"]
}
## Security Group http redirect
module "http_redirect_sg" {
    source = "../sg"
    name = "http_redirect_sg"
    vpc_id = var.vpc_id
    port = 8080
    cidr_blocks = ["0.0.0.0/0"]
}

## ELB
resource "aws_lb" "lb" {
    name = var.lb_name
    load_balancer_type = var.load_balancer_type
    internal = false
    idle_timeout = 60
    enable_deletion_protection = false

    subnets = var.lb_subnets

    access_logs {
      bucket = var.access_log_bucket
      enabled = true
    }

    security_groups = [ 
        module.http_sg.security_group_id,
        module.https_sg.security_group_id,
        module.http_redirect_sg.security_group_id,
    ]
}

## ELB http Listener
resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.lb.arn
    port = "80"
    protocol = "HTTP"

    default_action {
        type = "fixed-response"

        fixed_response {
            content_type = "text/plain"
            message_body = "This is HTTP"
            status_code = "200"
        }
    }
}

## Get Certificate
data "aws_acm_certificate" "test_cert" {
    domain = var.acm_domain
}

## ELB https Listener
resource "aws_lb_listener" "https" {
    load_balancer_arn = aws_lb.lb.arn
    port = "443"
    protocol = "HTTPS"
    certificate_arn = data.aws_acm_certificate.test_cert.arn
    ssl_policy = "ELBSecurityPolicy-2016-08"
    default_action {
        type = "fixed-response"

        fixed_response {
            content_type = "text/plain"
            message_body = "This is HTTP"
            status_code = "200"
        }
    }
}
## ELB http to https Listener
resource "aws_lb_listener" "redirect_http_to_https" {
    load_balancer_arn = aws_lb.lb.arn
    port = "8080"
    protocol = "HTTP"

    default_action {
        type = "redirect"

        redirect {
            port = "443"
            protocol = "HTTPS"
            status_code = "HTTP_301"
        }
    }
}

## ECS listener
resource "aws_lb_listener_rule" "lister_ecs" {
    listener_arn = aws_lb_listener.http.arn
    priority = 100

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.target_ecs.arn
    }

    condition {
        path_pattern {
            values = ["/*"]
        }
    }
}

## ECS target group
resource "aws_lb_target_group" "target_ecs" {
    name = "terraform-target"
    target_type = "ip"
    vpc_id = var.vpc_id
    port = 80
    protocol = "HTTP"
    deregistration_delay = 300

    health_check {
      path = "/"
      healthy_threshold = 5
      unhealthy_threshold = 2
      timeout = 5
      interval = 30
      matcher = 200
      port = "traffic-port"
      protocol = "HTTP"
    }
}

## ELB output
output "alb_dns_name" {
    value = aws_lb.lb.dns_name
}
output "alb_zone_id" {
    value = aws_lb.lb.zone_id
}
output "alb_arn" {
    value = aws_lb.lb.arn
}
## Output target group arn
output "ecs_target_group_arn" {
    value = aws_lb_target_group.target_ecs.arn
}