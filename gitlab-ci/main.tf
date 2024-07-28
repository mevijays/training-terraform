terraform {
  backend "http" {}
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.60.0"
    }
  }
}

provider "aws" {
   region = "us-west-2"
}
resource "aws_vpc" "dev" {
  cidr_block = "192.168.1.0/24"
}
