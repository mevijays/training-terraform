# Module: azure-network

Provisions a VNet, a set of subnets (via `for_each`), and a single NSG attached to all subnets.

## Usage

```hcl
module "network" {
  source              = "../../modules/azure-network"
  name                = "novapay-dev"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = ["10.10.0.0/16"]
  subnets = {
    web = "10.10.1.0/24"
    app = "10.10.2.0/24"
    db  = "10.10.3.0/24"
  }
  tags = local.common_tags
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | string | — | Base name (e.g., `novapay-dev`) |
| `address_space` | list(string) | — | VNet CIDR(s) |
| `subnets` | map(string) | — | name → CIDR |
| `resource_group_name` | string | — | RG to create resources in |
| `location` | string | — | Azure region |
| `tags` | map(string) | `{}` | Tags to apply |

## Outputs

| Name | Description |
|---|---|
| `vnet_id` | VNet resource ID |
| `vnet_name` | VNet name |
| `subnet_ids` | map of subnet name → ID |
| `nsg_id` | NSG ID |
