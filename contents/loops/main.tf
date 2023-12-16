terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
locals {
  provider_region = "us-west-2"
  tags            = ["dev", "uat", "prod"]
}
provider "aws" {
  region = local.provider_region
}
resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/22"
  tags       = { "Name" = "labvpc" }
}
data "aws_availability_zones" "available" {
  state = "available"
}
variable "private_subnet" {
  type    = list(string)
  default = ["192.168.0.0/24", "192.168.1.0/24", "192.168.2.0/24"]
}
variable "is_create_subnet" {
  type = bool
  default = true
}
resource "aws_subnet" "private" {
  count             = var.is_create_subnet ? length(var.private_subnet) : 0
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${local.tags[count.index]}-subnet"
  }
}
/*
resource "aws_subnet" "name" {
  for_each = toset(data.aws_availability_zones.main.names)
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 2, index(data.aws_availability_zones.main.names, each.key))
  availability_zone = each.key
}

resource "aws_subnet" "main" {
  count =  length(data.aws_availability_zones.main.names)
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 2, count.index)
  availability_zone = data.aws_availability_zones.main.names[count.index]
}
*/
