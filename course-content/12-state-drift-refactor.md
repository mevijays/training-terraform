# Module 12 — State Drift, Refactor, Moved, Removed

> **Exam objective (004 NEW/expanded):** Resource drift, `terraform refresh`, refresh-only, `moved` blocks, `removed` blocks, state refactor.

## Why this matters

In any long-lived environment, the real world drifts from your code: someone tweaks a tag in the portal, an autoscaler resizes a node, a hotfix is applied. Terraform 1.x added safer ways to reconcile.

## Theory

### What "drift" is

**Drift** = the real cloud resource doesn't match what's recorded in state. Two flavors:

1. **Out-of-band changes** — someone changed it outside Terraform.
2. **Provider/API changes** — the cloud added a default the provider now reports.

Either way, Terraform will show a `~ update in-place` (or worse, `-/+` replace) on the next plan.

### `terraform refresh` and refresh-only mode

`terraform refresh` updates state to match real-world resources, **without changing the cloud**. It's been deprecated as a top-level command in favor of:

```bash
terraform plan -refresh-only
terraform apply -refresh-only
```

The `-refresh-only` mode is safer because it shows you the drift as a plan and asks before updating state.

### `moved` blocks

Use case: you're refactoring your code and want to **rename** a resource without destroying and re-creating it.

Old way: `terraform state mv` (CLI command, manual, easy to forget on teammates' machines).

New way: a `moved` block, committed to source control. Apply it once; everyone's state updates automatically.

```hcl
# Before:
resource "azurerm_resource_group" "rg" { ... }

# After:
resource "azurerm_resource_group" "main" { ... }

moved {
  from = azurerm_resource_group.rg
  to   = azurerm_resource_group.main
}
```

On next apply, Terraform records the rename in state. After everyone has applied, you can delete the `moved` block.

Use cases for `moved`:
- Renaming resources
- Moving into/out of modules
- Refactoring `count` → `for_each`

```hcl
moved {
  from = aws_instance.web[0]
  to   = aws_instance.web["us-east-1a"]
}
```

### `removed` blocks (Terraform 1.7+)

Use case: you want to stop managing a resource (let it stay alive in the cloud), without using `terraform state rm` on every machine.

```hcl
# Old:
# resource "azurerm_storage_account" "legacy" { ... }   ← deleted from code

removed {
  from = azurerm_storage_account.legacy
  lifecycle {
    destroy = false   # keep the cloud resource alive
  }
}
```

Set `destroy = true` to actually destroy it; `false` removes it from state only.

After everyone's applied, you can delete the `removed` block.

### State refactor patterns

| Goal | Tool |
|---|---|
| Rename resource | `moved` block |
| Move into a module | `moved` block (with module address) |
| Move out of a module | `moved` block |
| Stop managing without deleting | `removed { lifecycle { destroy = false } }` |
| Switch `count` → `for_each` | `moved` block with explicit keys |
| Replace a resource | `terraform apply -replace=<address>` |

### `terraform taint` (deprecated)

In older Terraform you'd run `terraform taint <addr>` to force re-creation. Modern equivalent: `terraform apply -replace=<addr>`. Exam may still mention `taint` for awareness.

### Analogy: a postal mail-forwarding card

When you move house, you tell the post office "deliver mail addressed to the old address to the new one." That's a `moved` block — the resource didn't change, only its label.

`removed` is the opposite: "stop forwarding mail to this address" — and you can choose whether to demolish the house at the same time.

## Lab — Detect drift, rename with `moved`, retire with `removed`

**Goal:** see drift detection and the new refactor blocks in action.

1. `mkdir -p ~/tf-labs/12-drift && cd ~/tf-labs/12-drift`.
2. `main.tf`:
   ```hcl
   terraform {
     required_providers {
       azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
     }
   }
   provider "azurerm" { features {} }

   resource "azurerm_resource_group" "rg" {
     name     = "rg-drift-lab"
     location = "eastus"
     tags     = { env = "training" }
   }
   ```
3. Apply.
4. **Cause drift** by editing the tag in the portal (or CLI):
   ```bash
   az group update -n rg-drift-lab --set tags.env=manual-edit
   ```
5. Run `terraform plan -refresh-only`. You'll see the drift in state vs. reality.
6. `terraform apply -refresh-only` — updates state to match reality without changing cloud.
7. Now `terraform plan` again — Terraform wants to put `env = "training"` back. That's reconciliation: your code is now the source of truth.
8. **Refactor with `moved`** — rename `rg` to `main`:
   ```hcl
   resource "azurerm_resource_group" "main" {
     name     = "rg-drift-lab"
     location = "eastus"
     tags     = { env = "training" }
   }

   moved {
     from = azurerm_resource_group.rg
     to   = azurerm_resource_group.main
   }
   ```
9. `terraform plan` should show only the move, **no destroy/create**.
10. `terraform apply -auto-approve`. Verify with `terraform state list`.
11. **Retire with `removed`** — stop managing the RG without deleting it:
    ```hcl
    # remove the resource block, replace with:
    removed {
      from = azurerm_resource_group.main
      lifecycle { destroy = false }
    }
    ```
12. Apply. `terraform state list` should now be empty; the RG still exists in Azure.
13. Manually `az group delete -n rg-drift-lab --yes` to clean up.

## Trainer notes

- Show that `moved` blocks can stay in code forever (idempotent) — but it's cleaner to remove them once everyone has applied.
- Discussion: "When is drift a feature, not a bug?" e.g. autoscaling groups, RDS minor version auto-upgrades — handle with `ignore_changes` from Module 8.

## Next

➡ [Module 13 — Custom Validation and Checks](13-custom-validation-checks.md)
⬅ [Module 11 — Remote State and Locking](11-remote-state-locking.md)
