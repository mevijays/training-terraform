terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.89.0"
    }
  }
  backend "azurerm" {
      resource_group_name  = "yourrg"
      storage_account_name = "vaccountname"
      container_name       = "state-container"
      key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}
