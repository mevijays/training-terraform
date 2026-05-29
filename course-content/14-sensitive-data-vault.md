# Module 14 — Sensitive Data and Vault

> **Exam objective (004 NEW/expanded):** Describe secure secret injection best practices, Vault integration, ephemeral values, write-only arguments.

## Why this matters

Secrets land in state. Secrets land in logs. Secrets land in PR comments. Terraform 1.10+ gave us new tools (`ephemeral`, write-only arguments) precisely because the old patterns kept leaking.

## Theory

### Where secrets leak from

1. **State** — most resource attributes are recorded in state, often unencrypted on disk.
2. **Plan output** — strings printed to the terminal end up in CI logs and PR comments.
3. **`.tfvars` files** — easy to commit by mistake.
4. **Provider environment** — `TF_LOG=DEBUG` can include secrets.

### Tier 1 — `sensitive = true`

Marks an output (or variable) as sensitive. CLI redacts it as `<sensitive>`:

```hcl
output "db_password" {
  value     = azurerm_postgresql_flexible_server.demo.administrator_password
  sensitive = true
}
```

This **does not encrypt state**. It only hides from CLI display.

### Tier 2 — fetch from a secret manager at plan time

Pull secrets from Vault / Azure Key Vault / AWS Secrets Manager via a `data` source:

```hcl
data "azurerm_key_vault_secret" "db" {
  name         = "db-password"
  key_vault_id = data.azurerm_key_vault.shared.id
}

resource "azurerm_postgresql_flexible_server" "demo" {
  administrator_password = data.azurerm_key_vault_secret.db.value
  # ...
}
```

Problem: that secret **still lands in state**, because the resource attribute requires it.

### Tier 3 — ephemeral values (Terraform 1.10+, exam-relevant)

`ephemeral` values are evaluated at plan/apply time but **never written to state**. Use ephemeral resources and ephemeral input variables:

```hcl
variable "db_admin_password" {
  type      = string
  sensitive = true
  ephemeral = true
}

ephemeral "azurerm_key_vault_secret" "db" {
  name         = "db-password"
  key_vault_id = data.azurerm_key_vault.shared.id
}
```

Ephemeral values exist only in memory during the run.

### Tier 4 — write-only arguments

Some resource attributes can be set as **write-only**. They're sent to the cloud API but not recorded in state, similar to ephemeral.

```hcl
resource "azurerm_postgresql_flexible_server" "demo" {
  # ...
  administrator_password_wo         = ephemeral.azurerm_key_vault_secret.db.value
  administrator_password_wo_version = 1
}
```

Bumping `..._wo_version` is how you tell Terraform "the write-only value has changed, send it again."

### Vault integration

The HashiCorp Vault provider lets Terraform read short-lived dynamic credentials at plan time:

```hcl
provider "vault" {}

data "vault_kv_secret_v2" "db" {
  mount = "kv"
  name  = "prod/db"
}
```

Pair this with ephemeral / write-only to avoid state leakage.

### Analogy: a courier delivering a letter

- `sensitive = true` — the letter is in a clear envelope but with "PRIVATE" stamped on it. Anyone with the envelope can still read it.
- Pulling from Key Vault into state — the letter is opened and photocopied at the front desk.
- `ephemeral` — the courier hands the letter directly to the recipient and never makes a copy.
- Write-only arguments — the letter is dictated to a typist who writes it on the recipient's machine, with no transcript kept anywhere else.

### Secret rotation

Best pattern:
1. Store secret in Vault/Key Vault.
2. Fetch via `ephemeral` data source.
3. Pass to the resource via a `_wo` (write-only) argument.
4. To rotate: update the secret in Vault, bump `_wo_version`, run apply.

No `.tfvars`. No state. No leaks.

## Lab — Use Key Vault with ephemeral + write-only

**Goal:** create a PostgreSQL server whose admin password comes from Key Vault and never lands in state.

1. `mkdir -p ~/tf-labs/14-secrets && cd ~/tf-labs/14-secrets`.
2. Bootstrap Key Vault with the CLI:
   ```bash
   RG=rg-secrets-lab
   KV=kvsecretslab$RANDOM
   az group create -n $RG -l eastus
   az keyvault create -n $KV -g $RG -l eastus
   az keyvault secret set --vault-name $KV --name db-password --value "$(openssl rand -base64 24)"
   echo "Key Vault: $KV"
   ```
3. `main.tf`:
   ```hcl
   terraform {
     required_version = ">= 1.10.0"
     required_providers {
       azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
     }
   }
   provider "azurerm" { features {} }

   variable "kv_name" { type = string }

   data "azurerm_client_config" "current" {}

   data "azurerm_key_vault" "shared" {
     name                = var.kv_name
     resource_group_name = "rg-secrets-lab"
   }

   ephemeral "azurerm_key_vault_secret" "db_password" {
     name         = "db-password"
     key_vault_id = data.azurerm_key_vault.shared.id
   }

   resource "azurerm_postgresql_flexible_server" "demo" {
     name                          = "psqlsecretslab"
     resource_group_name           = "rg-secrets-lab"
     location                      = "eastus"
     version                       = "16"
     administrator_login           = "psqladmin"
     administrator_password_wo     = ephemeral.azurerm_key_vault_secret.db_password.value
     administrator_password_wo_version = 1
     sku_name                      = "B_Standard_B1ms"
     storage_mb                    = 32768
     zone                          = "1"
   }

   output "server_fqdn" { value = azurerm_postgresql_flexible_server.demo.fqdn }
   ```
4. `terraform init && terraform apply -var "kv_name=$KV" -auto-approve`.
5. Inspect state: `terraform state show azurerm_postgresql_flexible_server.demo`. **The password should NOT appear.**
6. Rotate the secret in Vault and bump `_wo_version` to 2. Apply. Confirm only the password attribute is updated.
7. Destroy: `terraform destroy -auto-approve -var "kv_name=$KV"` and `az group delete -n rg-secrets-lab --yes`.

## Trainer notes

- Show that `terraform show -json` confirms ephemeral values aren't in state.
- Discussion: "What if the provider doesn't yet expose a `_wo` argument?" — file a feature request; in the meantime, use a fetch+pass pattern and accept the state risk, or generate the secret outside Terraform and only store its handle/ID.
- Exam alert: 004 explicitly names ephemeral values and write-only arguments. They were not on 003.

## Next

➡ [Module 15 — Import and CLI Tools](15-import-cli.md)
⬅ [Module 13 — Custom Validation and Checks](13-custom-validation-checks.md)
