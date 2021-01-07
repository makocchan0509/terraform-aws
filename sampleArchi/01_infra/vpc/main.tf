## The template will creatre vpc ,public subnet and private subnet on 2 AZ. 
## VPC
resource "aws_vpc" "sample-archi" {
    cidr_block = "15.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "terraform"
    }
}

## IGW
resource "aws_internet_gateway" "sample-igw" {
    vpc_id = aws_vpc.sample-archi.id

    tags = {
        Name = "terraform"
    }
}

## Public subnet 1a
resource "aws_subnet" "sample-public" {
    vpc_id = aws_vpc.sample-archi.id
    cidr_block = "15.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone = "ap-northeast-1a"

    tags = {
        Name = "terraform-public"
    }
}

## Public subnet 1c
resource "aws_subnet" "sample-public2" {
    vpc_id = aws_vpc.sample-archi.id
    cidr_block = "15.0.2.0/24"
    map_public_ip_on_launch = true
    availability_zone = "ap-northeast-1c"

    tags = {
        Name = "terraform-public2"
    }
}

## Public route table
resource "aws_route_table" "public-route" {
    vpc_id =  aws_vpc.sample-archi.id
}

## Public route
resource "aws_route" "public-route" {
    route_table_id = aws_route_table.public-route.id
    gateway_id = aws_internet_gateway.sample-igw.id
    destination_cidr_block = "0.0.0.0/0"
}

## Public route 1a association
resource "aws_route_table_association" "public-route"{
    subnet_id = aws_subnet.sample-public.id
    route_table_id = aws_route_table.public-route.id
}

## Public route 1c association
resource "aws_route_table_association" "public-route2"{
    subnet_id = aws_subnet.sample-public2.id
    route_table_id = aws_route_table.public-route.id
}

## Private subnet 1a
resource "aws_subnet" "sample-private" {
    vpc_id = aws_vpc.sample-archi.id
    cidr_block = "15.0.10.0/24"
    availability_zone = "ap-northeast-1a"
    map_public_ip_on_launch = false
    tags = {
        Name = "terraform-private"
    }
}

## Private subnet 1c
resource "aws_subnet" "sample-private2" {
    vpc_id = aws_vpc.sample-archi.id
    cidr_block = "15.0.11.0/24"
    availability_zone = "ap-northeast-1c"
    map_public_ip_on_launch = false
    tags = {
        Name = "terraform-private2"
    }
}

## Private route table for 1a
resource "aws_route_table" "private-route" {
     vpc_id =  aws_vpc.sample-archi.id
}
## Private route for 1a
resource "aws_route" "private-route" {
    route_table_id = aws_route_table.private-route.id
    nat_gateway_id = aws_nat_gateway.sample-nat.id
    destination_cidr_block = "0.0.0.0/0"
}
## Private route table for 1c
resource "aws_route_table" "private-route2" {
     vpc_id =  aws_vpc.sample-archi.id
}
## Private route for 1c
resource "aws_route" "private-route2" {
    route_table_id = aws_route_table.private-route2.id
    nat_gateway_id = aws_nat_gateway.sample-nat2.id
    destination_cidr_block = "0.0.0.0/0"
}

## Private route 1a association
resource "aws_route_table_association" "private-route" {
    subnet_id = aws_subnet.sample-private.id
    route_table_id = aws_route_table.private-route.id
}
## Private route 1c association
resource "aws_route_table_association" "private-route2" {
    subnet_id = aws_subnet.sample-private2.id
    route_table_id = aws_route_table.private-route2.id
}

## Elastic IP for 1a NAT
resource "aws_eip" "nat-gateway" {
    vpc = true
    depends_on = [aws_internet_gateway.sample-igw]
    tags = {
        Name = "terraform"
    }
}

## Elastic IP for 1c NAT
resource "aws_eip" "nat-gateway2" {
    vpc = true
    depends_on = [aws_internet_gateway.sample-igw]
    tags = {
        Name = "terraform"
    }
}

## NAT Gateway for 1a
resource "aws_nat_gateway" "sample-nat" {
    allocation_id = aws_eip.nat-gateway.id
    subnet_id = aws_subnet.sample-public.id
    depends_on = [aws_internet_gateway.sample-igw]
    tags = {
        Name = "terraform"
    }
}

## NAT Gateway for 1c
resource "aws_nat_gateway" "sample-nat2" {
    allocation_id = aws_eip.nat-gateway2.id
    subnet_id = aws_subnet.sample-public2.id
    depends_on = [aws_internet_gateway.sample-igw]
    tags = {
        Name = "terraform"
    }
}

## VPC output
output "vpc_id" {
    value = aws_vpc.sample-archi.id
}
output "vpc_cidr_block" {
    value = aws_vpc.sample-archi.cidr_block
}
output "subnet_private_1_id" {
    value = aws_subnet.sample-private.id
}
output "subnet_private_2_id" {
    value = aws_subnet.sample-private2.id
}
