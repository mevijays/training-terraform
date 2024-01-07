variable "vm_type" {
  default = "t2.micro"
}
variable "ami_id" {
  default = null
}
variable "vpc_id" {
  default = null
}
variable "availability_zone" {
  default = null
}
variable "key_name" {
  default = "aws"
}
variable "public_key" {
  default = null
}
variable "user_data" {
  default = null
}
variable "ec2_subnet" {
  default = null
}