variable "env"            { type = string; default = "prod" }
variable "azure_location" {
  type    = string
  default = "westeurope"   # prod must be westeurope (Keyvault precondition)
}
variable "aws_region"     { type = string; default = "us-east-1" }
variable "vnet_cidr"      { type = string; default = "10.30.0.0/16" }

variable "subnets" {
  type = map(string)
  default = {
    web = "10.30.1.0/24"
    app = "10.30.2.0/24"
    db  = "10.30.3.0/24"
  }
}

variable "admin_ssh_public_key" { type = string }
