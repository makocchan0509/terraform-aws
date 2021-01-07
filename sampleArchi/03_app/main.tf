
# Ref vpc
data "aws_vpc" "vpc" {
    filter {
        name   = "tag:Name"
        values = ["terraform"] # insert value here
    }
}
#Ref public subnet
data "aws_subnet" "private" {
    filter {
        name   = "tag:Name"
        values = ["terraform-private"] # insert value here
    }
}
#Ref public subnet
data "aws_subnet" "private2" {
    filter {
        name   = "tag:Name"
        values = ["terraform-private2"] # insert value here
    }
}

data "aws_lb_target_group" "ecs_target" {
    name = "terraform-target"
}

data "aws_iam_role" "ecs_exec_role" {
    name = "ecsTaskExecution"
}

data "aws_iam_role" "ecs_event_role" {
    name = "ecsEventsRole"
}

module "create_ecs" {
    source = "./ecs"
    vpc_id = data.aws_vpc.vpc.id
    ecs_subnets = [data.aws_subnet.private.id,data.aws_subnet.private2.id]
    vpc_cidr_block = data.aws_vpc.vpc.cidr_block
    ecs_target_group_arn = data.aws_lb_target_group.ecs_target.arn
    ecs_task_execution_arn = data.aws_iam_role.ecs_exec_role.arn
    ecs_event_arn = data.aws_iam_role.ecs_event_role.arn
}

module "create_ecs_event" {
    source = "./cloudwatchevent"
    ecs_event_arn = data.aws_iam_role.ecs_event_role.arn
    ecs_cluster_arn = module.create_ecs.ecs_cluster_arn
    ecs_batch_arn = module.create_ecs.ecs_batch_arn
    ecs_subnets = [data.aws_subnet.private.id]
}
