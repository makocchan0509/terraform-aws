variable ecs_event_arn {}
variable ecs_cluster_arn {}
variable ecs_batch_arn {}
variable ecs_subnets {
    type = list(string)
}


resource "aws_cloudwatch_event_rule" "batch_event" {
    name = "terraform-batch"
    description = "important batch"
    schedule_expression = "cron(*/2 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "batch_event" {
    target_id = "terraform-batch"
    rule = aws_cloudwatch_event_rule.batch_event.name
    role_arn = var.ecs_event_arn
    arn = var.ecs_cluster_arn

    ecs_target {
        launch_type = "FARGATE"
        task_count = 1
        platform_version = "1.3.0"
        task_definition_arn = var.ecs_batch_arn

        network_configuration {
          assign_public_ip = "false"
          subnets = var.ecs_subnets
        }
    }
}