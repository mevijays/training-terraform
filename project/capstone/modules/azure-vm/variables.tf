variable "name"                 { type = string }
variable "resource_group_name"  { type = string }
variable "location"             { type = string }
variable "subnet_id"            { type = string }

variable "size" {
  type    = string
  default = "Standard_B1s"
}

variable "admin_username" {
  type    = string
  default = "novapay"
}

variable "admin_ssh_public_key" {
  type        = string
  description = "SSH public key for admin user (cat ~/.ssh/id_rsa.pub)."
}

variable "tags" {
  type    = map(string)
  default = {}
}
