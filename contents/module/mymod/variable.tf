variable "file_name" {
  default = "myfile"
  type = string
  validation {
    condition = length(var.file_name) <= 5
    error_message = "Error!.. file name given is not less than five charector long"
  }
}
variable "file_content" {
  type = string
  default = "welcome page"
}