variable "vpc_id" {}
variable "ecs_subnets" {
    type = list(string)
}
variable "vpc_cidr_block" {}
variable "ecs_target_group_arn" {}
variable "ecs_task_execution_arn" {}
variable "ecs_event_arn" {}


resource "aws_ecs_cluster" "cluster" {
    name = "terraform-cluster"
}

resource "aws_ecs_task_definition" "task" {
    family = "terraform-task"
    cpu = "256"
    memory = "512"
    network_mode = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    container_definitions = file("./ecs/container_definitions.json")
    execution_role_arn = var.ecs_task_execution_arn
}

resource "aws_ecs_task_definition" "batch" {
    family = "terraform-batch"
    cpu = "256"
    memory = "512"
    network_mode = "awsvpc"
    requires_compatibilities = [ "FARGATE" ]
    container_definitions = file("./ecs/batch_container_definitions.json")
    execution_role_arn = var.ecs_event_arn
}

resource "aws_ecs_service" "service" {
    name = "terraform-svc"
    cluster = aws_ecs_cluster.cluster.arn
    task_definition = aws_ecs_task_definition.task.arn
    desired_count = 2
    launch_type = "FARGATE"
    platform_version = "1.3.0"
    health_check_grace_period_seconds = 60

    network_configuration {
        assign_public_ip = false
        security_groups = [module.create_ecs_sg.security_group_id]

        subnets = var.ecs_subnets
    }

    load_balancer {
        target_group_arn = var.ecs_target_group_arn
        container_name = "nginx"
        container_port = 80
    }

    lifecycle {
        ignore_changes = [task_definition]
    }
}

## Security group for ecs nginx
module "create_ecs_sg" {
    source = "../../02_middle/sg"
    name = "nginx-sg"
    vpc_id = var.vpc_id
    port = 80
    cidr_blocks = [var.vpc_cidr_block]
}

output "ecs_cluster_arn" {
    value = aws_ecs_cluster.cluster.arn
}
output "ecs_batch_arn" {
    value = aws_ecs_task_definition.batch.arn
}