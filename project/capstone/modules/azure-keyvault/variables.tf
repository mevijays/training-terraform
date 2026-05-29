variable "name" {
  type        = string
  description = "Base name (e.g., novapay-dev)."
}

variable "env" {
  type        = string
  description = "Environment (dev/stage/prod)."
  validation {
    condition     = contains(["dev", "stage", "prod"], var.env)
    error_message = "env must be dev, stage, or prod."
  }
}

variable "resource_group_name" { type = string }
variable "location"            { type = string }

variable "tags" {
  type    = map(string)
  default = {}
}
