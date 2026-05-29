# Module 15 — Import and CLI Tools

> **Exam objective:** Import existing infrastructure, inspect state, use verbose logging.

## Why this matters

You will inherit cloud resources you didn't create. The exam asks how to bring them under Terraform control, how to look around in state, and when to crank up logging to debug provider issues.

## Theory

### Why import?

You have an Azure resource group made by hand 18 months ago. You want it managed by Terraform without destroying and re-creating it (it has live workloads). **Import** writes that resource into state, mapping it to a `resource` block in your code.

### Two ways to import

#### 1. CLI: `terraform import`

```bash
terraform import azurerm_resource_group.legacy /subscriptions/abc/resourceGroups/rg-legacy
```

- Requires a matching `resource` block in your code (even if empty-ish).
- Maps the cloud ID → state.
- Does **not** generate code for you.

Typical flow:
1. Write a stub `resource` block.
2. Run `terraform import` to populate state.
3. Run `terraform plan` — it'll show what attributes differ.
4. Edit the resource block to match reality until `plan` shows "No changes".

#### 2. `import` block (Terraform 1.5+, preferred for 004)

A declarative, file-based way:

```hcl
import {
  to = azurerm_resource_group.legacy
  id = "/subscriptions/abc/resourceGroups/rg-legacy"
}

resource "azurerm_resource_group" "legacy" {
  name     = "rg-legacy"
  location = "eastus"
}
```

Then `terraform plan -generate-config-out=generated.tf` can auto-generate a starter `resource` block from the cloud:

```bash
terraform plan -generate-config-out=generated.tf
```

The generated file is a starting point — review and edit it before committing.

After the import block has done its job (and you've applied), you can delete it.

### Inspecting state

| Command | Purpose |
|---|---|
| `terraform state list` | All addresses in state |
| `terraform state show <addr>` | Full attributes for one resource |
| `terraform output` | Show outputs |
| `terraform output -json` | Outputs as JSON (CI-friendly) |
| `terraform show` | Human-readable full state |
| `terraform show -json` | Full state as JSON |
| `terraform graph` | Dependency graph in DOT format |
| `terraform providers` | Provider tree, including by-module |

### Verbose logging

When provider behavior is mysterious, set `TF_LOG`:

```bash
export TF_LOG=DEBUG          # values: TRACE, DEBUG, INFO, WARN, ERROR, OFF
export TF_LOG_PATH=tf.log     # write to a file
terraform plan
unset TF_LOG TF_LOG_PATH
```

Levels:

- `TRACE` — everything (very noisy, shows full API requests/responses including bodies)
- `DEBUG` — most useful for "why is the provider doing this?"
- `INFO` — high-level lifecycle events
- `WARN` / `ERROR` — only when things go wrong

You can also target only core or only providers: `TF_LOG_CORE=DEBUG`, `TF_LOG_PROVIDER=TRACE`.

**Warning:** TRACE logs can contain secrets. Treat log files as sensitive.

### Other useful CLI tools

```bash
terraform fmt -recursive          # format all .tf files
terraform validate                # syntax + internal consistency
terraform console                 # REPL for expressions and functions
terraform workspace list/select/new   # local workspaces (different state files)
terraform refresh                 # deprecated — use plan -refresh-only
terraform get -update             # refresh module sources
terraform force-unlock <LOCK_ID>  # break a stuck remote lock
```

### Analogy: a building inspector taking over from a previous owner

When you take over a building from a previous owner who didn't keep records:

- You walk through and **inventory** what exists (`terraform state list`).
- You **document each item** in your own ledger (`terraform import`).
- For each thing you found, you decide: keep it, modify it, or remove it (your code).
- You take **photos** to debug confusing situations (`TF_LOG`).

## Lab — Import an existing resource

**Goal:** create something with the CLI, then bring it under Terraform.

1. `mkdir -p ~/tf-labs/15-import && cd ~/tf-labs/15-import`.
2. Manually create a resource group:
   ```bash
   az group create -n rg-import-lab -l eastus --tags owner=manual env=test
   ```
3. Create `main.tf`:
   ```hcl
   terraform {
     required_providers {
       azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
     }
   }
   provider "azurerm" { features {} }

   import {
     to = azurerm_resource_group.imported
     id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/rg-import-lab"
   }

   data "azurerm_client_config" "current" {}
   ```
4. Generate config:
   ```bash
   terraform init
   terraform plan -generate-config-out=generated.tf
   ```
5. Inspect `generated.tf`. Move/clean its `resource "azurerm_resource_group" "imported"` block into `main.tf`. Delete `generated.tf`.
6. `terraform apply -auto-approve`.
7. Verify:
   ```bash
   terraform state list           # shows azurerm_resource_group.imported
   terraform state show azurerm_resource_group.imported
   ```
8. Remove the `import { }` block. Run `terraform plan` — should be "No changes".
9. Try verbose logging:
   ```bash
   export TF_LOG=DEBUG
   export TF_LOG_PATH=tf.log
   terraform plan
   unset TF_LOG TF_LOG_PATH
   wc -l tf.log    # surprisingly chatty
   ```
10. Destroy: `terraform destroy -auto-approve`.

## Trainer notes

- Show students how `terraform plan -generate-config-out=...` is the modern, less painful way to do import — versus writing the resource block by hand and iterating.
- Discussion: "Why doesn't Terraform auto-import everything in a subscription?" — that would be terrifyingly easy to break with one config error.
- Gotcha: import only works for *managed* resource types. You can't import data-only sources or modules; you import the underlying resources.

## Next

➡ [Module 16 — HCP Terraform](16-hcp-terraform.md)
⬅ [Module 14 — Sensitive Data and Vault](14-sensitive-data-vault.md)
