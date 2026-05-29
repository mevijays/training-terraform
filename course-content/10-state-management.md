# Module 10 — State Management Basics

> **Exam objective:** Describe default local backend; explain state file purpose, structure, and best practices.

## Why this matters

State is the most-misunderstood part of Terraform. Lose it and Terraform thinks nothing exists (and tries to create everything fresh). Leak it and you've leaked secrets.

## Theory

### What state is

`terraform.tfstate` is a JSON file that maps:

```
your code address ─────► real cloud resource ID + attributes
```

Example fragment:

```json
{
  "resources": [
    {
      "type": "azurerm_resource_group",
      "name": "demo",
      "instances": [{
        "attributes": {
          "id": "/subscriptions/abc/resourceGroups/rg-demo",
          "name": "rg-demo",
          "location": "eastus"
        }
      }]
    }
  ]
}
```

Without this, Terraform would have to **list and inspect every cloud resource** on every run to know what it owns. That doesn't scale.

### Analogy: a shopkeeper's ledger

A shopkeeper doesn't take inventory by walking every aisle each morning. They consult the ledger: "I bought 12 of these, sold 4 — should have 8 left." If the ledger is lost, the shop is in chaos.

### State file responsibilities

1. **Identity mapping** — which cloud resource corresponds to which Terraform address.
2. **Attribute caching** — fast access to attributes without re-querying.
3. **Dependency tracking** — recorded for accurate destroy ordering.
4. **Metadata** — Terraform version, lineage, serial number, provider versions.

### The default: local backend

Out of the box, Terraform stores state in `./terraform.tfstate` next to your `.tf` files. A backup goes to `terraform.tfstate.backup` after each apply.

This is fine for learning, **not** for team use:

| Problem | Why it bites you |
|---|---|
| State file lives on one laptop | Teammates can't run apply |
| No locking | Two people apply → corruption |
| Secrets in state are on disk in cleartext | Easy to commit by mistake |
| No history | Can't diff or roll back |

For real work, use **remote state** (Module 11).

### NEVER commit state to Git

State files can contain:
- Resource IDs
- Database passwords (if a resource has them as attributes)
- Bearer tokens
- Private keys

Always have `.tfstate` and `.terraform/` in `.gitignore`:

```
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl   # ← actually you SHOULD commit this one
```

### State CLI commands (the ones you'll use)

```bash
terraform state list                          # show all addresses in state
terraform state show <address>                # show one resource's full attributes
terraform state mv <src> <dst>                # rename in state (no cloud change)
terraform state rm <address>                  # forget a resource (does NOT delete it)
terraform state pull > state.json             # dump current state
terraform state push state.json               # upload state (DANGEROUS)
terraform state replace-provider <old> <new>  # change provider source
```

`state rm` is your friend when you want Terraform to stop managing something without deleting it.

### Sensitive data in state

Some resource attributes are *always* in state (it's how Terraform works). The exam expects you to know:

- State **can** contain secrets.
- The right answers are: encrypt state at rest (remote backends do this), restrict access, and **use ephemeral / write-only arguments** for one-time secrets (covered in Module 14).
- `sensitive = true` on outputs hides them from CLI but does NOT remove them from state.

## Lab — Explore local state

**Goal:** read, modify, and recover state by hand.

1. `mkdir -p ~/tf-labs/10-state && cd ~/tf-labs/10-state`.
2. Create `main.tf`:
   ```hcl
   terraform {
     required_providers {
       random = { source = "hashicorp/random", version = "~> 3.6" }
       local  = { source = "hashicorp/local",  version = "~> 2.5" }
     }
   }

   resource "random_pet" "name" {
     length = 2
   }

   resource "local_file" "demo" {
     filename = "${path.module}/${random_pet.name.id}.txt"
     content  = "Hello from ${random_pet.name.id}"
   }
   ```
3. `terraform init && terraform apply -auto-approve`.
4. Inspect state:
   ```bash
   terraform state list
   terraform state show random_pet.name
   cat terraform.tfstate | jq .
   ```
5. Rename a resource in code: change `random_pet.name` → `random_pet.demo_name`. If you `apply` directly, Terraform will destroy and re-create. Instead:
   ```bash
   terraform state mv random_pet.name random_pet.demo_name
   terraform plan   # should show "No changes"
   ```
6. Tell Terraform to forget about the file (without deleting it):
   ```bash
   terraform state rm local_file.demo
   ls *.txt   # file still exists
   ```
7. Re-import it (preview of Module 15):
   ```bash
   terraform import local_file.demo $(pwd)/$(ls *.txt | head -1)
   ```
8. Destroy.

## Trainer notes

- Show that the state file is plain JSON — students often assume it's a binary or encrypted format.
- War story: someone committed `terraform.tfstate` to GitHub and rotated keys for 3 days. Easy mistake.
- Foreshadow Module 11: "Everything we just did breaks the moment two people share this folder."

## Next

➡ [Module 11 — Remote State and Locking](11-remote-state-locking.md)
⬅ [Module 9 — Modules](09-modules.md)
