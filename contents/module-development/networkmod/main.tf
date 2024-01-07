resource "random_string" "this" {
  special = false
  length  = 6
  lower   = true
  upper   = false
}
variable "cidr_block" {
  default = "10.0.0.0/16"
}
variable "az" {
  default = null
}
variable "subnet_cidr" {
  default = []
  type    = list(string)
}
variable "subnet_az" {
  default = []
  type    = list(string)
}
variable "is_create_vpc" {
  type    = bool
  default = false
}
variable "name_sg" {
  default = null
}
data "aws_vpc" "this" {
  default = true
}
resource "aws_vpc" "this" {
  count      = var.is_create_vpc ? 1 : 0
  cidr_block = var.cidr_block
}
resource "aws_subnet" "this" {
  count             = var.is_create_vpc ? length(var.subnet_cidr) : 0
  vpc_id            = aws_vpc.this[0].id
  cidr_block        = var.subnet_cidr[count.index]
  availability_zone = var.subnet_az[count.index]
}
output "aws_vpc_id" {
  value = var.is_create_vpc ? aws_vpc.this[0].id : "Using default vpc"
}
output "subnet_ids" {
  value = aws_subnet.this[*].id
}
