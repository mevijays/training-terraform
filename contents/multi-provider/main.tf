# terraform block, anything inside this block you change, you have to run terraform init again.
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.73.0"
    }
    google = {
      source = "hashicorp/google"
      version = "6.8.0"
    }
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.7.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}

provider "google" {
  # Configuration options
  project = "tflabs"
}
resource "azurerm_resource_group" "main" {
  name     = "my-resource-group"
  location = "East US"
}
resource "aws_vpc" "main" {
  cidr_block = "192.168.1.0/24"
  
}

resource "google_compute_network" "vpc_network" {
  name                    = "my-vpc-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet1" {
  name          = "my-subnet-1"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
}

provider "azurerm" {
  features {}
  subscription_id = "xxxx-xxxxxxxx-xxxxxx-xxxx-xxxxx"
}

resource "azurerm_virtual_network" "main" {
  name                = "my-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "East US"
  resource_group_name = azurerm_resource_group.main.name

  subnet {
    name           = "subnet1"
    address_prefixes = ["10.0.1.0/24"]
  }

  subnet {
    name           = "subnet2"
    address_prefixes = ["10.0.2.0/24"]
  }
}
