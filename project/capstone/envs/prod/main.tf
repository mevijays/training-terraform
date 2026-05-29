terraform {
  required_version = ">= 1.12.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
    aws     = { source = "hashicorp/aws",     version = "~> 5.80" }
  }
}

provider "azurerm" { features {} }
provider "aws"     { region = var.aws_region }

locals {
  name = "novapay-${var.env}"
  common_tags = {
    project    = "novapay"
    env        = var.env
    owner      = "platform-team"
    managed_by = "terraform"
    criticality = "high"
  }
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.name}"
  location = var.azure_location
  tags     = local.common_tags

  # Prod-only safeguard
  lifecycle {
    prevent_destroy = true
  }
}

module "network"       { source = "../../modules/azure-network"; name = local.name; resource_group_name = azurerm_resource_group.this.name; location = azurerm_resource_group.this.location; address_space = [var.vnet_cidr]; subnets = var.subnets; tags = local.common_tags }
module "keyvault"      { source = "../../modules/azure-keyvault"; name = local.name; env = var.env; resource_group_name = azurerm_resource_group.this.name; location = azurerm_resource_group.this.location; tags = local.common_tags }
module "vm"            { source = "../../modules/azure-vm"; name = local.name; resource_group_name = azurerm_resource_group.this.name; location = azurerm_resource_group.this.location; subnet_id = module.network.subnet_ids["web"]; admin_ssh_public_key = var.admin_ssh_public_key; size = "Standard_B2ms"; tags = local.common_tags }
module "static_site"   { source = "../../modules/aws-static-site"; name = local.name; tags = local.common_tags }
module "observability" { source = "../../modules/observability"; name = local.name; resource_group_name = azurerm_resource_group.this.name; location = azurerm_resource_group.this.location; vnet_id = module.network.vnet_id; tags = local.common_tags }

# Cross-resource healthcheck (Module 13 — `check` block, non-blocking)
check "web_subnet_present" {
  assert {
    condition     = contains(keys(module.network.subnet_ids), "web")
    error_message = "Expected a 'web' subnet — networking module misconfigured."
  }
}
