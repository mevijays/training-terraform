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
  region = "us-west-1"
}
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*"]
  }

}
resource "aws_vpc" "main" {
  cidr_block = "192.168.1.0/24"
}

resource "aws_instance" "main" {
  ami = data.aws_ami.ubuntu.id      //arguments (implicit dependancy)
  instance_type = "t3.small"
  depends_on = [ aws_vpc.main ]   //meta argument
}