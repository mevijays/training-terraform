terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.17.0"
    }
  }
  required_version = "~> 1.5.6"
}
variable "a" {
  type = string
}
provider "aws" {
  //region = "us-west-2"
region =   var.a != "" ? var.a : "us-east-2"

}
variable "is_create_vpc" {
  type = bool
  default = true
}
resource "aws_vpc" "main" {
    count = var.is_create_vpc ? 1 : 0
    //count = 1
  cidr_block = "192.168.10.0/24"
}