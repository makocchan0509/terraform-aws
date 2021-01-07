module "web_server" {
    source  = "./http_server"
    instance_type = "t2.micro"
}

output "example_id" {
    value = module.web_server.example_id
}

output "public_dns" {
    value = module.web_server.public_dns
}