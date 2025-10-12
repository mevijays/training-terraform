terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.76.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}
locals {
  aws_vpc_cidr = "192.168.0.0/16"
}
resource "aws_vpc" "main" {
  cidr_block = local.aws_vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "dev-vpc"
  }
  
}
data "aws_availability_zones" "available" {
  state = "available"
}
resource "aws_subnet" "main" {
  for_each = toset(data.aws_availability_zones.available.names)
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8,  index(data.aws_availability_zones.available.names, each.value))
    availability_zone = each.value
}
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "dev-igw"
    }
}
resource "aws_route_table" "main" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }
    tags = {
        Name = "dev-rt"
    }
}
resource "aws_route_table_association" "main" {
    for_each = aws_subnet.main
    subnet_id = each.value.id
    route_table_id = aws_route_table.main.id
}
resource "aws_security_group" "main" {
    vpc_id = aws_vpc.main.id
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
}
egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
}
}
data "aws_ami" "ubuntu" {
    most_recent = true
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    owners = ["099720109477"]
}
resource "aws_key_pair" "main" {
    public_key  = "rsa -xxxx"    
    key_name = "ubuntu"
}
resource "aws_instance" "main" {
  instance_type = "t2.micro"
    ami = data.aws_ami.ubuntu.id
    subnet_id = values(aws_subnet.main)[1].id
    vpc_security_group_ids = [aws_security_group.main.id]
    associate_public_ip_address = true
    key_name = aws_key_pair.main.key_name
    tags = {
        Name = "dev-instance"
    }
}
output "subnet_list" {
  value = aws_instance.main.public_ip
  description = "public ip of aws instance"
}
