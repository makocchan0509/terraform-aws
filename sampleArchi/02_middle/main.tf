## The template will create middle layer services.

#IAM Role
## IAM Policy document describe regions for ec2
data "aws_iam_policy_document" "allow_describe_regions" {
    statement {
        effect = "Allow"
        actions = ["ec2:DescribeRegions"]
        resources = ["*"]
    }
}
## Create IAM Role describe regions for EC2
module "describe_regions_for_ec2" {
    source = "./iam"
    roleName = "describeRegionsEC2"
    policyName = "describeRegions"
    identifier  = "ec2.amazonaws.com"
    policy = data.aws_iam_policy_document.allow_describe_regions.json
}

## IAM Policy ecs task exec
data "aws_iam_policy" "ecs_task_execution_role_policy" {
    arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

## IAM Policy document ecs task execution
data "aws_iam_policy_document" "ecs_task_execution" {
    source_json = data.aws_iam_policy.ecs_task_execution_role_policy.policy

    statement {
      effect = "Allow"
      actions = ["ssm:GetParameters","kms:Decrypt"]
      resources = ["*"]
    }
}

## Create IAM Role for ECS
module "create_role_ecs" {
    source = "./iam"
    roleName = "ecsTaskExecution"
    policyName = "ecs-task-execution"
    identifier  = "ecs-tasks.amazonaws.com"
    policy = data.aws_iam_policy_document.ecs_task_execution.json
}

## IAM Policy ec2 container service events
data "aws_iam_policy" "ecs_events_role_policy" {
    arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}

## Create IAM Role describe regions for EC2
module "ecs_events_role" {
    source = "./iam"
    roleName = "ecsEventsRole"
    policyName = "ecsEventsPolicy"
    identifier  = "events.amazonaws.com"
    policy = data.aws_iam_policy.ecs_events_role_policy.policy
}

## S3 bucket
module "create_s3_bucket" {
    source = "./s3"
    bucket_name = "masem-alb-log-terraform"
}

## CloudWatch log group
module "create_cw_log" {
    source = "./cloudwatch"
    name = "/ecs/terraform"
}
module "create_cw_log_sche" {
    source = "./cloudwatch"
    name = "/ecs-scheduled-tasks/terraform"
}

# Ref vpc
data "aws_vpc" "vpc" {
    filter {
        name   = "tag:Name"
        values = ["terraform"] # insert value here
    }
}
#Ref public subnet
data "aws_subnet" "public" {
    filter {
        name   = "tag:Name"
        values = ["terraform-public"] # insert value here
    }
}
#Ref public subnet
data "aws_subnet" "public2" {
    filter {
        name   = "tag:Name"
        values = ["terraform-public2"] # insert value here
    }
}

## Elastic Load Balancer
module "create_elb" {
    source = "./elb"
    vpc_id = data.aws_vpc.vpc.id
    lb_subnets = [data.aws_subnet.public.id,data.aws_subnet.public2.id]
    access_log_bucket = module.create_s3_bucket.access_log_bucket_id
}

module "create_kms" {
    source = "./kms"
    alias_name = "alias/terraform"
}

module "create_str_ssm" {
    source = "./ssm"
    name = "/db/username"
    value = "root"
    type = "String"
    description = "database user managed by terraform"
}

module "create_secure_ssm" {
    source = "./ssm"
    name = "/db/password"
    value = "password"
    type = "SecureString"
    description = "database password managed by terraform"
}