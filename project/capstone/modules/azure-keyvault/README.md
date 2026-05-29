# Module: azure-keyvault

Creates a Key Vault (RBAC-mode), grants the deploying identity Secrets Officer, and writes a generated 24-char random password as `db-password`.

Demonstrates:
- Variable `validation` block on `env`.
- `lifecycle { precondition }` enforcing prod-must-be-westeurope.
- `random_password` resource feeding `azurerm_key_vault_secret`.

## Usage

```hcl
module "keyvault" {
  source              = "../../modules/azure-keyvault"
  name                = "novapay-dev"
  env                 = "dev"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = local.common_tags
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | string | — | Base name (e.g., `novapay-dev`) |
| `env` | string | — | One of `dev`, `stage`, `prod` (validated) |
| `resource_group_name` | string | — | RG |
| `location` | string | — | Region (must be `westeurope` if env=prod) |
| `tags` | map(string) | `{}` | Tags |

## Outputs

| Name | Description |
|---|---|
| `id` | KV ID |
| `name` | KV name |
| `uri` | KV URI |
| `db_password_secret_id` | Versioned URI of the DB password secret |

## Notes

- `purge_protection_enabled = false` for the lab so you can fully destroy and re-create. **Enable for real prod.**
- `enable_rbac_authorization = true` uses Azure RBAC instead of legacy access policies.
- The caller (you, via `azurerm_client_config.current.object_id`) is granted Secrets Officer so apply can write the seed secret.
