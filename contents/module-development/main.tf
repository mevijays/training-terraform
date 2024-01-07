terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}
data "aws_ami" "main" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server*"]
  }
}

module "network" {
  source        = "./networkmod"
  is_create_vpc = true
  cidr_block    = "10.10.0.0/16"
  subnet_az     = ["us-west-2a", "us-west-2b"]
  subnet_cidr   = ["10.10.1.0/24", "10.10.2.0/24"]
}
/*
module "ec2" {
  source = "./mainmod"
  ami_id = data.aws_ami.main.id
  vm_type = "t2.micro"
  vpc_id = module.network.aws_vpc_id
  key_name = "aws-key"
  public_key = file("./aws-key.pub")
  ec2_subnet =  module.network.subnet_ids[0]
}
*/