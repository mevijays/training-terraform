terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "2.4.0"
    }
  }
}

provider "local" {
  # Configuration options
}

module "main" {
  source = "./mymod"
  file_name = "vijay"
  file_content = "welcome page this is terraform module class"
}
