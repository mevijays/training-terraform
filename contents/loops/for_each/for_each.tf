terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "2.4.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "5.16.1"
    }
  }
}

provider "local" {
  # Configuration options
}
provider "aws" {
  region = "us-west-2"
}
provider "aws" {
  region = "us-east-1"
  alias = "east1"
}



locals {
  names = {
    	fileone = "today is rainy"
	    filetwo = "my class is terraform"
  }
}

resource "local_file" "main" {
  for_each = local.names
  content = "Hello ${each.value}"
  filename = "${path.module}/${each.key}.txt"
}
data "aws_vpc" "main" {
  default = true
}
data "aws_subnets" "main" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}
locals {
  db = {
    subnet-04d3157deec1bc4a1 = "us-west-2c"
    subnet-01fc4064c06fdd7da = "us-west-2a"
  }
}
resource "aws_instance" "main" {
  for_each = local.db
  instance_type = "t2.micro"
  ami = data.aws_ami.ubuntu.id
  subnet_id = each.key
  availability_zone = each.value
  tags = {
    Name = "Server ${each.key}"
  }
}