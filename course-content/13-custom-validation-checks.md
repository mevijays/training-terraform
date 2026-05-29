# Module 13 — Custom Validation and Checks

> **Exam objective (004 NEW):** Validate configuration using custom conditions — variable `validation`, `precondition`, `postcondition`, `check` blocks.

## Why this matters

You can stop bad configs from reaching cloud APIs by validating them in Terraform itself. The 004 exam explicitly tests these features (they didn't all exist on 003).

## Theory

There are four ways to add custom validation, each running at a different stage:

| Construct | Where | When it runs |
|---|---|---|
| Variable `validation` block | Inside `variable` block | At plan time, before resources are processed |
| `precondition` | Inside resource/data/output `lifecycle` | At plan time, before this resource is processed |
| `postcondition` | Inside resource/data `lifecycle` | After this resource is read/created |
| `check` block | Top-level | After plan/apply, non-blocking |

### Variable validation

Catches bad input early:

```hcl
variable "env" {
  type = string
  validation {
    condition     = contains(["dev", "stage", "prod"], var.env)
    error_message = "env must be one of: dev, stage, prod."
  }
}

variable "cidr" {
  type = string
  validation {
    condition     = can(cidrhost(var.cidr, 0))
    error_message = "cidr must be a valid CIDR block."
  }
}
```

`can()` returns true if its expression doesn't error — handy for type/format checks.

### `precondition`

A safety check **before** Terraform reads/creates a resource. Failing it halts the plan with a clear error.

```hcl
data "azurerm_resource_group" "shared" {
  name = "rg-shared"

  lifecycle {
    precondition {
      condition     = var.env != "prod" || var.allow_prod
      error_message = "Production environments require var.allow_prod=true."
    }
  }
}
```

### `postcondition`

A guarantee **after** Terraform reads/created a resource. Fail if the cloud doesn't match what you expected.

```hcl
data "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  key_vault_id = data.azurerm_key_vault.shared.id

  lifecycle {
    postcondition {
      condition     = length(self.value) >= 16
      error_message = "Database password must be ≥ 16 characters."
    }
  }
}
```

`self` inside a postcondition refers to the resource itself.

### `check` blocks (1.5+)

Top-level, **non-blocking** assertions that run at the end of plan/apply. They produce warnings, not errors — perfect for ongoing health/compliance signals you don't want to break deploys for.

```hcl
check "health" {
  data "http" "endpoint" {
    url = "https://${azurerm_linux_web_app.demo.default_hostname}/healthz"
  }

  assert {
    condition     = data.http.endpoint.status_code == 200
    error_message = "Endpoint did not return 200 OK."
  }
}
```

### Analogy: airport security

| Construct | Airport equivalent |
|---|---|
| `validation` | Check-in: "your ticket is for a real flight" |
| `precondition` | Boarding pass scan: "you're allowed past this gate" |
| `postcondition` | Cabin crew: "your seat actually exists" |
| `check` | Post-flight survey: "everything OK?" — non-blocking |

### When to use which

- **Bad inputs?** `validation` in the variable.
- **Wrong context (env, account, role)?** `precondition`.
- **Cloud responded with something unexpected?** `postcondition`.
- **Ongoing compliance / monitoring?** `check`.

## Lab — All four constructs in one config

**Goal:** see each in action.

1. `mkdir -p ~/tf-labs/13-validation && cd ~/tf-labs/13-validation`.
2. `main.tf`:
   ```hcl
   terraform {
     required_providers {
       azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
       http    = { source = "hashicorp/http",    version = "~> 3.4" }
     }
   }
   provider "azurerm" { features {} }

   variable "env" {
     type    = string
     default = "dev"
     validation {
       condition     = contains(["dev", "stage", "prod"], var.env)
       error_message = "env must be dev, stage, or prod."
     }
   }

   variable "location" {
     type    = string
     default = "eastus"
     validation {
       condition     = contains(["eastus", "westus2", "westeurope"], var.location)
       error_message = "location must be eastus, westus2, or westeurope."
     }
   }

   resource "azurerm_resource_group" "demo" {
     name     = "rg-validation-${var.env}"
     location = var.location

     lifecycle {
       precondition {
         condition     = var.env != "prod" || var.location == "westeurope"
         error_message = "Prod deployments must go to westeurope."
       }
       postcondition {
         condition     = self.location == var.location
         error_message = "Created location did not match requested."
       }
     }
   }

   check "rg_visible" {
     data "azurerm_resource_group" "lookup" {
       name = azurerm_resource_group.demo.name
     }
     assert {
       condition     = data.azurerm_resource_group.lookup.id == azurerm_resource_group.demo.id
       error_message = "RG lookup did not match created RG ID."
     }
   }
   ```
3. Try `terraform plan -var="env=foo"` — variable validation fires.
4. `terraform plan -var="env=prod" -var="location=eastus"` — precondition fires.
5. `terraform apply -auto-approve` (defaults) — succeeds; check should pass.
6. Destroy.

## Trainer notes

- Common confusion: `precondition` vs `postcondition` — show it with the airport analogy.
- Discussion: "Why use `check` rather than `postcondition`?" — `check` doesn't fail the apply; useful for monitoring without halting deploys.
- Exam trap: `validation` lives in a *variable* block; `precondition`/`postcondition` live in a *lifecycle* block; `check` is *top-level*.

## Next

➡ [Module 14 — Sensitive Data and Vault](14-sensitive-data-vault.md)
⬅ [Module 12 — State Drift, Refactor, Moved, Removed](12-state-drift-refactor.md)
