terraform {
  required_version = "~> 1.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.56.1"
    }
  }
}
provider "aws" {
  region = "us-west-2"
}
data "aws_ami" "main" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server*"]
  }
}
locals {
  cidr = "192.168.0.0/16"
}
data "aws_availability_zones" "this" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block = local.cidr
}

resource "aws_subnet" "main" {
  count                   = length(data.aws_availability_zones.this.names)
  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.this.names[count.index]
  cidr_block              = cidrsubnet(local.cidr, 8, count.index)
  map_public_ip_on_launch = true
}
resource "aws_internet_gateway" "name" {
  vpc_id = aws_vpc.main.id
}
resource "aws_route_table" "name" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block ="0.0.0.0/0"
    gateway_id = aws_internet_gateway.name.id
  }
}
resource "aws_route_table_association" "name" {
  count = length(aws_subnet.main[*].id)
  subnet_id = aws_subnet.main[count.index].id
  route_table_id = aws_route_table.name.id
}

resource "aws_security_group" "name" {
  name   = "vpcsg"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "mysg" }
}
resource "aws_key_pair" "main" {
  key_name   = "cloud-key"
  public_key = file("./awskey.pub")
}
resource "aws_instance" "name" {
  ami                    = data.aws_ami.main.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.name.id]
  key_name               = aws_key_pair.main.key_name
  subnet_id              = aws_subnet.main[0].id
}
output "public-ip" {
  value = aws_instance.name.public_ip
}
