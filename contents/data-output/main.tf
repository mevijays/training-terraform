terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.13.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "us-east-2"
}

// Define Data here...
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }
  owners = ["099720109477"] # Canonical
}


data "aws_availability_zones" "available" {
  state = "available"
}
data "aws_ec2_instance_type" "example" {
  instance_type = "t2.micro"
}
data "aws_vpc" "vpc" {
  default = true
}

data "aws_subnets" "example" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

data "aws_subnet" "example" {
  for_each = toset(data.aws_subnets.example.ids)
  id       = each.value
}

output "subnet_cidr_blocks" {
  value = [for s in data.aws_subnet.example : s.cidr_block] //you see here the loop example.
}


// Define Outputs you want here...
output "instance_ami" {
  value = data.aws_ami.ubuntu.id
}

output "available_zones" {
  value = data.aws_availability_zones.available.names[*]
}
output "available_first_zone" {
  value = data.aws_availability_zones.available.names[0]
}

output "default_vpc_cidr_block" {
  value = data.aws_vpc.vpc.cidr_block
}
output "default_vpc_id" {
  value = data.aws_vpc.vpc.id
}
/*
resource "aws_vpc" "main" {
  cidr_block = "172.31.0.0/16"
  tags = { name="vpcdefault" }
}
resource "aws_instance" "main" {
  ami = data.aws_ami.ubuntu.id
  instance_type = data.aws_ec2_instance_type.example.id
}
*/
