terraform {
  backend "s3" {
    bucket = "mevijay-tfstate"
    key    = "krnetwork.tfstate"
    region = "us-west-2"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.14.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = local.dev_region
}

resource "aws_vpc" "main" {
  count      = 2
  cidr_block = "192.168.${count.index}.0/24"
}

resource "aws_subnet" "main" {
  cidr_block        = "192.168.1.0/26"
  availability_zone = local.subnet_az
  vpc_id            = aws_vpc.main[1].id
}

resource "aws_instance" "main" {
  count             = 2
  ami               = data.aws_ami.ubuntu.id
  instance_type     = local.instance_size
  subnet_id         = aws_subnet.main.id
  availability_zone = local.subnet_az
  tags = {
    Name = "myvm${count.index}"
  }
}