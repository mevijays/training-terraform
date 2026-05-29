# Module 5 — Variables and Outputs

> **Exam objective:** Demonstrate use of variables and outputs, including collection and structural types.

## Why this matters

Hardcoded values are a code smell. Variables make your config reusable across environments; outputs make data available to humans and downstream Terraform.

## Theory

### Input variables

Variables let callers customize a config without editing it.

```hcl
variable "location" {
  type        = string
  default     = "eastus"
  description = "Azure region to deploy into"
}

variable "vm_count" {
  type    = number
  default = 1
}
```

### How to set variable values (precedence — lowest to highest)

1. `default` in the variable block
2. Environment variables (`TF_VAR_location=westus`)
3. `terraform.tfvars` / `*.auto.tfvars` (auto-loaded)
4. Any `*.tfvars` file passed with `-var-file=`
5. `-var` flag on the CLI

Later wins. CLI `-var` always beats files.

### Variable types

**Primitives:** `string`, `number`, `bool`.

**Collection types:**

```hcl
variable "subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "tags" {
  type = map(string)
  default = {
    env   = "dev"
    owner = "platform"
  }
}

variable "allowed_ports" {
  type    = set(number)
  default = [80, 443]
}
```

**Structural types:**

```hcl
variable "vm_config" {
  type = object({
    name = string
    size = string
    tags = map(string)
  })
}

variable "vms" {
  type = list(object({
    name = string
    size = string
  }))
}
```

### Analogy: function parameters

Think of a Terraform config as a big function. Variables are its parameters. Outputs are its return values. Modules let you compose them like normal functions.

### Outputs

```hcl
output "rg_name" {
  value       = azurerm_resource_group.demo.name
  description = "Name of the created resource group"
}

output "db_password" {
  value     = azurerm_postgresql_flexible_server.demo.administrator_password
  sensitive = true   # masks from CLI; still visible in state
}
```

Outputs serve two purposes:
1. **Human-readable** after `apply` — names, URLs, IPs.
2. **Inter-module data flow** — a module's output is the parent's data.

### Locals

`locals` are private intermediate values inside one config — like local variables inside a function:

```hcl
locals {
  common_tags = merge(var.tags, {
    managed_by = "terraform"
    module     = "network"
  })
}

resource "azurerm_virtual_network" "demo" {
  # ...
  tags = local.common_tags
}
```

Use `locals` to:
- Avoid repetition
- Compute values once
- Name complex expressions

## Lab — Variables and outputs in practice

**Goal:** parameterize a small Azure config; expose outputs.

1. `mkdir -p ~/tf-labs/05-vars && cd ~/tf-labs/05-vars`.
2. Create `variables.tf`:
   ```hcl
   variable "location" {
     type    = string
     default = "eastus"
   }
   variable "env" {
     type = string
   }
   variable "tags" {
     type = map(string)
     default = {
       managed_by = "terraform"
     }
   }
   ```
3. Create `main.tf`:
   ```hcl
   terraform {
     required_providers {
       azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
     }
   }
   provider "azurerm" { features {} }

   locals {
     name_prefix = "rg-${var.env}"
     all_tags    = merge(var.tags, { env = var.env })
   }

   resource "azurerm_resource_group" "demo" {
     name     = "${local.name_prefix}-vars-lab"
     location = var.location
     tags     = local.all_tags
   }
   ```
4. Create `outputs.tf`:
   ```hcl
   output "rg_id"   { value = azurerm_resource_group.demo.id }
   output "rg_name" { value = azurerm_resource_group.demo.name }
   output "tags"    { value = local.all_tags }
   ```
5. Create `dev.tfvars`:
   ```hcl
   env = "dev"
   tags = {
     owner   = "platform-team"
     project = "vars-lab"
   }
   ```
6. Run:
   ```bash
   terraform init
   terraform apply -var-file=dev.tfvars -auto-approve
   ```
7. Try a CLI override: `terraform apply -var-file=dev.tfvars -var="location=westus2"` — note how CLI wins.
8. Inspect outputs: `terraform output` and `terraform output -json`.
9. Destroy.

## Trainer notes

- Pop quiz: "If I set `TF_VAR_env=prod` in my shell and pass `-var-file=dev.tfvars` with `env=dev`, what wins?" (dev — file beats env var.)
- Gotcha: `sensitive = true` hides from CLI output but **does not encrypt state**. Module 14 covers real secret handling.

## Next

➡ [Module 6 — Resources and Data Sources](06-resources-data.md)
⬅ [Module 4 — Core Workflow](04-core-workflow.md)
