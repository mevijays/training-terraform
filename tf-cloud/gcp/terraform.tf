terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.50.0"
    }
  }
   cloud {
    organization = "mevijays"
    workspaces {
      name = "training-terraform"
    }
  }
}
