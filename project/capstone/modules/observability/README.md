# Module: observability

A Log Analytics workspace and an optional diagnostic setting linking a passed-in resource (here, the VNet) to that workspace.

## Usage

```hcl
module "observability" {
  source              = "../../modules/observability"
  name                = "novapay-dev"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  vnet_id             = module.network.vnet_id   # optional
  tags                = local.common_tags
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | string | — | Base name |
| `resource_group_name` | string | — | RG |
| `location` | string | — | Region |
| `vnet_id` | string | `null` | Optional VNet to wire diagnostic setting to |
| `tags` | map(string) | `{}` | Tags |

## Outputs

| Name | Description |
|---|---|
| `workspace_id` | LAW resource ID |
| `workspace_name` | LAW name |

## Notes

- Retention defaults to 30 days. Set higher (90+) for prod and you'll pay more per GB.
- Extend the module by accepting a `map(string)` of `resource_id → diagnostic_settings_name` to wire many resources at once.
