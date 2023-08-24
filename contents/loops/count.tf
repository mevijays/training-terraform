terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
locals {
  instance_size   = "t2.micro"
  provider_region = "us-east-2"
  tag_name        = "myvm"
  image_ami_id    = "ami-05d251e0fc338590c"
}

provider "aws" {
  region = local.provider_region
}
// Example 1
resource "aws_instance" "app_server" {
  count         = 2
  ami           = local.image_ami_id
  instance_type = local.instance_size
  tags = {
    Name = "${local.tag_name} ${count.index}"
  }
}

//Example 2
data "aws_vpc" "vpc" {
  default = true
}
data "aws_availability_zones" "available" {
  state = "available"
}
variable "private_subnet" {
  type    = list(string)
  default = ["10.0.2.0/24", "10.0.3.0/24"]
}
resource "aws_subnet" "private" {
  count                   = length(var.private_subnet)
  vpc_id                  = data.aws_vpc.vpc.id
  cidr_block              = var.private_subnet[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
}
