variable "name" {
  type        = string
  description = "Base name (e.g., novapay-dev)."
}

variable "tags" {
  type    = map(string)
  default = {}
}
