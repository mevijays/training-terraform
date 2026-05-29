# Module 7 — Expressions and Functions

> **Exam objective:** Use HCL and Terraform functions to write configuration.

## Why this matters

HCL is more than just `key = value`. Real configs use loops, conditionals, type conversions, string templates, and built-in functions. The exam tests whether you can read an expression and predict its output.

## Theory

### Expression types

| Type | Example |
|---|---|
| Literal | `"prod"`, `42`, `true`, `null` |
| Reference | `var.env`, `azurerm_resource_group.x.id` |
| Arithmetic | `var.count * 2` |
| Comparison | `var.env == "prod"` |
| Logical | `var.enabled && var.env == "prod"` |
| Conditional (ternary) | `var.env == "prod" ? "Standard_DS3" : "Standard_DS1"` |
| For expressions | `[for s in var.subnets : cidrhost(s, 1)]` |
| Splat | `azurerm_virtual_network.all[*].id` |

### Conditional (ternary)

```hcl
account_replication_type = var.env == "prod" ? "GRS" : "LRS"
```

### For expressions

Build a list:
```hcl
[for name in var.names : upper(name)]
# ["DEV", "PROD"]
```

Build a map:
```hcl
{for vm in var.vms : vm.name => vm.size}
# {"web-1" = "Standard_DS1", "web-2" = "Standard_DS2"}
```

With a filter:
```hcl
[for vm in var.vms : vm.name if vm.size != "free"]
```

### Splat expressions

Get an attribute from every item:
```hcl
azurerm_subnet.all[*].id      # newer splat
azurerm_subnet.all.*.id       # legacy splat — same result
```

### Template strings

```hcl
name = "vm-${var.env}-${count.index + 1}"

multiline = <<EOT
This is line 1.
This is line ${var.env}.
EOT
```

### Functions

Terraform ships ~100 built-in functions. The exam doesn't ask you to memorize all of them, but you should know the categories:

| Category | Examples |
|---|---|
| **Numeric** | `min`, `max`, `abs`, `ceil`, `floor` |
| **String** | `upper`, `lower`, `format`, `replace`, `split`, `join`, `trimspace` |
| **Collection** | `length`, `concat`, `merge`, `keys`, `values`, `lookup`, `contains`, `flatten`, `distinct` |
| **Encoding** | `jsonencode`, `jsondecode`, `yamlencode`, `yamldecode`, `base64encode` |
| **Filesystem** | `file`, `templatefile`, `fileexists`, `pathexpand` |
| **Date/Time** | `timestamp`, `formatdate`, `timeadd` |
| **Hash/Crypto** | `md5`, `sha256`, `uuid`, `bcrypt` |
| **IP/Network** | `cidrhost`, `cidrnetmask`, `cidrsubnet` |
| **Type conversion** | `tostring`, `tonumber`, `tolist`, `tomap`, `toset` |

### Highly useful examples

```hcl
# Read a file
content = file("${path.module}/cloud-init.yaml")

# Render a template with variables
content = templatefile("${path.module}/init.tpl", {
  hostname = "web-1"
  env      = var.env
})

# Merge maps
tags = merge(var.default_tags, var.extra_tags)

# Carve subnets out of a CIDR
subnet_cidr = cidrsubnet("10.0.0.0/16", 8, 1)   # "10.0.1.0/24"

# Look up with fallback
size = lookup(var.sizes, var.env, "Standard_DS1_v2")
```

### Analogy: spreadsheet formulas

Functions in HCL are like Excel formulas — you compose `=SUM(A:A)`-style chains to produce a value. The big difference: HCL is **declarative and side-effect-free**. Functions can't read or write files at apply time; they're evaluated during plan.

## Lab — Build a config from data

**Goal:** use for-expressions, functions, and a template file together.

1. `mkdir -p ~/tf-labs/07-functions && cd ~/tf-labs/07-functions`.
2. Create `init.tpl`:
   ```
   #!/bin/bash
   echo "Hello, ${hostname}, env=${env}" > /tmp/info.txt
   ```
3. Create `main.tf`:
   ```hcl
   terraform {
     required_providers {
       local = { source = "hashicorp/local", version = "~> 2.5" }
     }
   }

   variable "envs" {
     type    = list(string)
     default = ["dev", "stage", "prod"]
   }

   locals {
     base_cidr   = "10.0.0.0/16"
     env_subnets = { for i, e in var.envs : e => cidrsubnet(local.base_cidr, 8, i) }
     scripts     = { for e in var.envs : e => templatefile("init.tpl", { hostname = "vm-${e}", env = e }) }
   }

   resource "local_file" "subnets" {
     filename = "${path.module}/out-subnets.json"
     content  = jsonencode(local.env_subnets)
   }

   resource "local_file" "scripts" {
     for_each = local.scripts
     filename = "${path.module}/init-${each.key}.sh"
     content  = each.value
   }

   output "subnets" { value = local.env_subnets }
   ```
4. Run `terraform init && terraform apply -auto-approve`.
5. Inspect `out-subnets.json` and each `init-*.sh`.
6. Try modifying `envs = ["dev", "prod"]`. Plan — observe what's destroyed and created.
7. Destroy.

## Trainer notes

- Live-demo `terraform console` — students rarely know it exists:
  ```bash
  terraform console
  > cidrsubnet("10.0.0.0/16", 8, 5)
  > [for n in ["a","b","c"] : upper(n)]
  ```
- Exam trap: `for_each` over a `list` requires `toset(...)`.

## Next

➡ [Module 8 — Dependencies and Lifecycle](08-dependencies-lifecycle.md)
⬅ [Module 6 — Resources and Data Sources](06-resources-data.md)
