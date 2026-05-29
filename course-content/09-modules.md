# Module 9 — Modules

> **Exam objective:** Contrast and use module sources, interact with inputs/outputs, describe variable scope, set module version.

## Why this matters

Modules are how Terraform code stays sane at scale. Without them you'd copy-paste the same VNet block 100 times. With them, you stamp out a tested, reusable pattern with a few lines.

## Theory

A **module** is just a folder of `.tf` files. Every Terraform config you write *is* a module — specifically, the **root module**. When that root module calls another folder, that's a **child module**.

### Analogy: functions

- Root module = your `main()` function.
- Child module = an imported library function.
- Inputs (variables) = function parameters.
- Outputs = return values.
- `source` = the import statement.
- `version` = pinning the library version.

### Module sources

A module's `source` argument tells Terraform where to fetch it:

| Source type | Example |
|---|---|
| Local path | `source = "./modules/vnet"` |
| Public Terraform Registry | `source = "Azure/network/azurerm", version = "5.3.0"` |
| Private Registry (HCP Terraform) | `source = "app.terraform.io/my-org/network/azurerm"` |
| Git (HTTPS) | `source = "git::https://github.com/me/tf-modules.git//vnet?ref=v1.2.0"` |
| Git (SSH) | `source = "git::ssh://git@github.com/me/tf-modules.git//vnet?ref=v1.2.0"` |
| GitHub shortcut | `source = "github.com/me/tf-modules//vnet?ref=v1.2.0"` |
| HTTP zip/tar | `source = "https://example.com/vnet-1.0.0.zip"` |
| S3 bucket | `source = "s3::https://s3.amazonaws.com/my-bucket/vnet.zip"` |

The `//` in Git/HTTP URLs is the path *within* the repo. The `?ref=` pins to a tag/branch/commit.

### Setting module versions

For **registry** sources only, you set version via the dedicated argument:

```hcl
module "network" {
  source  = "Azure/network/azurerm"
  version = "~> 5.0"
}
```

For **Git** sources, you encode the version in the `?ref=` query parameter — `version =` is **not allowed** there.

### Module inputs and outputs

A module's variables are its public API:

```hcl
# modules/vnet/variables.tf
variable "name"                 { type = string }
variable "address_space"        { type = list(string) }
variable "resource_group_name"  { type = string }
variable "location"             { type = string }
```

And outputs expose data:

```hcl
# modules/vnet/outputs.tf
output "id"             { value = azurerm_virtual_network.this.id }
output "subnet_ids"     { value = azurerm_subnet.this[*].id }
```

Caller:

```hcl
module "network" {
  source              = "./modules/vnet"
  name                = "vnet-prod"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location
}

resource "azurerm_subnet" "extra" {
  virtual_network_name = module.network.id   # ← consuming the output
  # ...
}
```

### Variable scope (004 calls this out)

- Variables defined in a child module are **only visible inside that module**.
- The caller passes values **explicitly** — there is no global scope.
- Outputs of one module can be passed as inputs to another via the root.
- `var.foo` in the root has **nothing to do with** `var.foo` in a child.

This isolation is on purpose: modules are units of encapsulation.

### Versioning your own modules

Best practice:

1. Put modules in their own Git repo (or use a monorepo with subfolders).
2. Tag releases with SemVer: `v1.0.0`, `v1.1.0`.
3. Pin consumers with `?ref=v1.0.0` (Git) or `version = "~> 1.0"` (registry).
4. Never push breaking changes to a previously-tagged version. Bump major version.

## Lab — Build and consume a module

**Goal:** create a local module for an Azure VNet+subnet; consume it from a root module.

1. Folder layout:
   ```bash
   mkdir -p ~/tf-labs/09-modules/{root,modules/vnet}
   cd ~/tf-labs/09-modules
   ```
2. `modules/vnet/main.tf`:
   ```hcl
   variable "name"                 { type = string }
   variable "address_space"        { type = list(string) }
   variable "resource_group_name"  { type = string }
   variable "location"             { type = string }
   variable "subnets" {
     type = map(string)
     default = {}
   }

   resource "azurerm_virtual_network" "this" {
     name                = var.name
     address_space       = var.address_space
     resource_group_name = var.resource_group_name
     location            = var.location
   }

   resource "azurerm_subnet" "this" {
     for_each             = var.subnets
     name                 = each.key
     virtual_network_name = azurerm_virtual_network.this.name
     resource_group_name  = var.resource_group_name
     address_prefixes     = [each.value]
   }

   output "vnet_id"    { value = azurerm_virtual_network.this.id }
   output "subnet_ids" { value = { for k, s in azurerm_subnet.this : k => s.id } }
   ```
3. `root/main.tf`:
   ```hcl
   terraform {
     required_providers {
       azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
     }
   }
   provider "azurerm" { features {} }

   resource "azurerm_resource_group" "demo" {
     name     = "rg-modules-lab"
     location = "eastus"
   }

   module "vnet_prod" {
     source              = "../modules/vnet"
     name                = "vnet-prod"
     address_space       = ["10.0.0.0/16"]
     resource_group_name = azurerm_resource_group.demo.name
     location            = azurerm_resource_group.demo.location
     subnets = {
       web = "10.0.1.0/24"
       app = "10.0.2.0/24"
     }
   }

   output "vnet_id"    { value = module.vnet_prod.vnet_id }
   output "subnet_ids" { value = module.vnet_prod.subnet_ids }
   ```
4. From `root/`: `terraform init && terraform apply -auto-approve`.
5. Try `terraform state list` — notice the module-prefixed addresses (`module.vnet_prod.azurerm_subnet.this["web"]`).
6. Now try pulling a module from the registry. Add to `root/main.tf`:
   ```hcl
   module "naming" {
     source  = "Azure/naming/azurerm"
     version = "~> 0.4"
     suffix  = ["modules-lab"]
   }
   ```
7. `terraform init` then `terraform plan` to see registry module behavior.
8. Destroy.

## Trainer notes

- Show what happens if you point `source` at a Git tag and someone *moves* that tag — Terraform won't re-pull unless you delete `.terraform/modules/`.
- Discussion: "When does a piece of config deserve its own module?" Rule of thumb: when it's used in 2+ places with substantially the same shape.

## Next

➡ [Module 10 — State Management Basics](10-state-management.md)
⬅ [Module 8 — Dependencies and Lifecycle](08-dependencies-lifecycle.md)
