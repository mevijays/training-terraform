# Module 8 — Dependencies and Lifecycle Rules

> **Exam objective (004 NEW):** `depends_on`, `create_before_destroy`, `prevent_destroy`, `ignore_changes`. Lifecycle rules are a named topic in the 004 exam.

## Why this matters

Terraform's dependency graph is usually right — but when it isn't, you'll see "cycle detected" errors or destructive replacements at 2 AM. Lifecycle rules let you control destruction order and protect critical resources.

## Theory

### How Terraform builds the dependency graph

Terraform builds a **DAG** (directed acyclic graph) of resources by reading your code:

```hcl
resource "azurerm_resource_group" "demo" { ... }

resource "azurerm_virtual_network" "demo" {
  resource_group_name = azurerm_resource_group.demo.name  # ← implicit dependency
}
```

Because `azurerm_virtual_network.demo` references `azurerm_resource_group.demo`, Terraform creates the RG first, then the VNet. On destroy, the order is reversed.

### `depends_on` — explicit dependency

Use when there is a real ordering that Terraform can't infer from references:

```hcl
resource "azurerm_role_assignment" "kv_access" {
  # ...
  depends_on = [azurerm_key_vault.demo]
}
```

A common case: a resource needs another to *exist and be ready*, but its config doesn't reference it directly. Use sparingly — references are preferred because they're self-documenting.

### Lifecycle rules

```hcl
resource "azurerm_storage_account" "demo" {
  # ...
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = true
    ignore_changes        = [tags["last_scan"]]
    replace_triggered_by  = [azurerm_resource_group.demo.id]
  }
}
```

#### `create_before_destroy = true`

Default order on a "forced replacement" is **destroy old → create new** (downtime). With `create_before_destroy`, Terraform creates the new one first, then destroys the old.

Analogy: replacing a tire. Default = jack the car up, remove old tire, put new one on. CBD = car magically has 5 wheels for a moment, swap, then drop wheel #5.

Caveat: the resource must support having two with the same logical role at once (different names, IPs, etc.).

#### `prevent_destroy = true`

Terraform will **error out** if a plan would destroy this resource. Good for prod databases, KMS keys, DNS zones. To actually destroy it, you remove the lifecycle rule first.

#### `ignore_changes`

Tells Terraform "I know this attribute might drift; don't try to fight it":

```hcl
lifecycle {
  ignore_changes = [
    tags["last_scanned_at"],   # set by an external scanner
    image_id,                  # AMI updated by autoscaling group
  ]
}
```

Use `ignore_changes = all` to ignore everything (rare).

#### `replace_triggered_by` (1.2+)

Forces replacement when another resource or attribute changes:

```hcl
resource "azurerm_linux_virtual_machine" "demo" {
  # ...
  lifecycle {
    replace_triggered_by = [azurerm_network_interface.demo.private_ip_address]
  }
}
```

#### `precondition` and `postcondition` (covered in Module 13)

### Analogy table

| Rule | Real-world equivalent |
|---|---|
| `create_before_destroy` | Move into your new house before selling the old one |
| `prevent_destroy` | A "do not demolish" sticker on a historic building |
| `ignore_changes` | "Don't worry about the paint color; the next tenant will repaint" |
| `replace_triggered_by` | "If the foundation cracks, rebuild the house" |

### Destroy-time provisioners and dependency edge cases

If you have a destroy-time provisioner that needs to talk to another resource, that resource must outlive yours during destroy. Use `depends_on` to record that. (Provisioners themselves are a discouraged escape hatch — try not to need them.)

## Lab — Lifecycle rules in action

**Goal:** observe `create_before_destroy` and `prevent_destroy` behavior.

1. `mkdir -p ~/tf-labs/08-lifecycle && cd ~/tf-labs/08-lifecycle`.
2. Create `main.tf`:
   ```hcl
   terraform {
     required_providers {
       random = { source = "hashicorp/random", version = "~> 3.6" }
       local  = { source = "hashicorp/local",  version = "~> 2.5" }
     }
   }

   resource "random_id" "name" {
     byte_length = 4
     keepers = {
       env = var.env
     }
   }

   variable "env" { default = "dev" }

   resource "local_file" "important" {
     filename = "${path.module}/critical-${random_id.name.hex}.txt"
     content  = "This is critical data for ${var.env}"

     lifecycle {
       create_before_destroy = true
       prevent_destroy       = true
     }
   }
   ```
3. `terraform init && terraform apply -auto-approve`.
4. Try to destroy: `terraform destroy`. It should **fail** because of `prevent_destroy`.
5. Now flip `env = "prod"` (in CLI: `terraform apply -var="env=prod"`). Because `random_id.name.keepers.env` changes, the random ID regenerates, which renames the file — but **`prevent_destroy` blocks the old file from being deleted**, so apply fails.
6. Remove `prevent_destroy = true` from the lifecycle block. Re-apply. This time you should see "1 to add, 1 to destroy" — and because of `create_before_destroy`, the new file is created before the old one is removed.
7. Inspect the working directory between phases to see both files briefly coexist.
8. Remove the lifecycle block entirely and destroy.

## Trainer notes

- Common student error: putting `lifecycle` outside the resource block (it must be inside).
- Show what happens in a CI pipeline when `prevent_destroy` fires — it's loud, which is good.
- Discussion: "When is `ignore_changes` a smell?" — when you're using it because of bad provider design or because you imported a resource without aligning config.

## Next

➡ [Module 9 — Modules](09-modules.md)
⬅ [Module 7 — Expressions and Functions](07-expressions-functions.md)
