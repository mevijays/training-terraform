# Module 6 — Resources and Data Sources

> **Exam objective:** Create and differentiate resource and data configuration; use resource addressing to connect resources.

## Why this matters

`resource` and `data` look almost identical in HCL but do completely opposite things: one creates, the other reads. Getting this distinction wrong leads to "why did Terraform try to delete my prod DB?" stories.

## Theory

### `resource` — Terraform owns it

```hcl
resource "azurerm_resource_group" "demo" {
  name     = "rg-demo"
  location = "eastus"
}
```

- Terraform **creates, updates, and destroys** this resource.
- It appears in state.
- Removing it from code (and running apply) **deletes** it from the cloud.

### `data` — Terraform reads it

```hcl
data "azurerm_resource_group" "existing" {
  name = "rg-shared"
}

output "shared_rg_id" {
  value = data.azurerm_resource_group.existing.id
}
```

- Terraform **never modifies** this resource.
- It's read at plan time and used as input.
- Removing it from code does nothing in the cloud.

### Analogy: writing vs reading a database row

- `resource` = `INSERT` / `UPDATE` / `DELETE` (you own the row).
- `data` = `SELECT` (you only look it up).

### Resource addresses

Every resource has a unique address: `<TYPE>.<NAME>`. With modules and counts:

| Address | Meaning |
|---|---|
| `azurerm_resource_group.demo` | A single resource |
| `module.network.azurerm_virtual_network.main` | Inside a module |
| `aws_instance.web[0]` | First item if using `count` |
| `aws_instance.web["us-east-1a"]` | A specific key if using `for_each` |

You'll use these addresses in:
- `terraform state` commands
- `terraform import`
- `terraform plan -target=`
- Cross-resource references

### Connecting resources by reference

Don't hardcode IDs. Reference them:

```hcl
resource "azurerm_resource_group" "demo" {
  name     = "rg-demo"
  location = "eastus"
}

resource "azurerm_virtual_network" "demo" {
  name                = "vnet-demo"
  location            = azurerm_resource_group.demo.location   # ← reference
  resource_group_name = azurerm_resource_group.demo.name       # ← reference
  address_space       = ["10.0.0.0/16"]
}
```

Two big benefits:
1. **Implicit dependency** — Terraform knows VNet depends on RG.
2. **No hardcoded values** — change the RG name once.

### Meta-arguments (recap)

Every resource and data block supports:

| Meta-argument | Purpose |
|---|---|
| `count` | Create N identical-ish copies (indexed by number) |
| `for_each` | Create one per key in a map/set |
| `depends_on` | Force an ordering Terraform can't infer |
| `provider` | Pick a specific provider alias |
| `lifecycle` | Customize create/update/destroy behavior (Module 8) |

`count` vs `for_each` quick guide:

- Use `count` when you literally just want N identical things.
- Use `for_each` when each instance has distinct config — and you want stable identifiers (so deleting #2 doesn't shift #3 → #2).

```hcl
resource "azurerm_storage_account" "envs" {
  for_each                 = toset(["dev", "stage", "prod"])
  name                     = "st${each.key}vijay"
  resource_group_name      = azurerm_resource_group.demo.name
  location                 = azurerm_resource_group.demo.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
# addresses: azurerm_storage_account.envs["dev"], ["stage"], ["prod"]
```

## Lab — Mix resources and data

**Goal:** read an existing resource group via data; create resources inside it.

1. `mkdir -p ~/tf-labs/06-resources && cd ~/tf-labs/06-resources`.
2. Pre-create a resource group manually (so we have something to look up):
   ```bash
   az group create --name rg-shared-lab --location eastus
   ```
3. Create `main.tf`:
   ```hcl
   terraform {
     required_providers {
       azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
     }
   }
   provider "azurerm" { features {} }

   data "azurerm_resource_group" "shared" {
     name = "rg-shared-lab"
   }

   resource "azurerm_storage_account" "labs" {
     for_each                 = toset(["alpha", "beta"])
     name                     = "stlab${each.key}vijay"
     resource_group_name      = data.azurerm_resource_group.shared.name
     location                 = data.azurerm_resource_group.shared.location
     account_tier             = "Standard"
     account_replication_type = "LRS"
   }

   output "rg_id"     { value = data.azurerm_resource_group.shared.id }
   output "sa_names"  { value = [for sa in azurerm_storage_account.labs : sa.name] }
   ```
4. `terraform init && terraform apply -auto-approve`.
5. Note how state contains the two storage accounts but **not** the resource group — Terraform only owns what it created.
6. Verify: deleting the resource group from Terraform won't try to delete it (it's just a `data` lookup).
7. Cleanup: `terraform destroy -auto-approve` and then `az group delete --name rg-shared-lab --yes`.

## Trainer notes

- Pop quiz: "I have `data \"aws_ami\" \"ubuntu\" {...}`. Will `terraform destroy` delete the AMI?" (No — data is read-only.)
- Show `terraform state list` to walk the address namespace.
- Gotcha: data sources can fail at plan time if the upstream resource doesn't exist yet. For dependencies between data and resource, use `depends_on` in the data block.

## Next

➡ [Module 7 — Expressions and Functions](07-expressions-functions.md)
⬅ [Module 5 — Variables and Outputs](05-variables-outputs.md)
