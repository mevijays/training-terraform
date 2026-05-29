# Module 4 — Core Workflow

> **Exam objective:** Use the core Terraform workflow (Write → Plan → Apply, plus `init`, `validate`, `destroy`, `fmt`).

## Why this matters

These six commands are the bulk of your day-to-day Terraform life. The exam asks "which command does X" frequently. Knowing the *order* and *side effects* of each is the goal.

## Theory

The official **Write → Plan → Apply** workflow:

```
   ┌──────────┐    ┌──────────┐    ┌──────────┐
   │  Write   │ → │   Plan   │ → │   Apply   │
   └──────────┘    └──────────┘    └──────────┘
       *.tf         show diff       make real
```

### Analogy: a Word document review

- **Write** = type the document.
- **Plan** = "Track Changes" — show what would happen if accepted.
- **Apply** = accept all changes and save.
- **Destroy** = delete the document.

### The six core commands

| Command | What it does | Side effects |
|---|---|---|
| `terraform init` | Downloads providers, initializes backend, creates `.terraform/` and lock file | Touches disk; never touches cloud |
| `terraform validate` | Checks syntax + internal consistency of config | Read-only; doesn't need credentials |
| `terraform plan` | Computes diff between state and desired config | Read-only on cloud; may refresh state |
| `terraform apply` | Executes the plan (creates/updates/destroys resources) | Mutates cloud + state |
| `terraform destroy` | Plan + apply, but for tearing everything down | Mutates cloud + state |
| `terraform fmt` | Rewrites `.tf` files in canonical style | Touches disk only |

### `terraform init` deep dive

What `init` actually does:

1. Reads `terraform` block — figures out required version, providers, backend.
2. Downloads providers into `.terraform/providers/`.
3. Initializes the **backend** (default = local; or remote if configured).
4. Writes/updates `.terraform.lock.hcl`.
5. Initializes child modules (downloads from registry/git).

You re-run `init` when:
- Adding/removing a provider
- Changing the backend
- Adding/removing modules
- Upgrading versions: `terraform init -upgrade`

### `terraform plan` deep dive

A plan shows three kinds of action:

| Symbol | Meaning |
|---|---|
| `+` | Create |
| `-` | Destroy |
| `~` | Update in place |
| `-/+` | Destroy and recreate (forces replacement) |
| `<=` | Read (data source) |

You can save a plan and apply it later:

```bash
terraform plan -out=mychange.tfplan
terraform apply mychange.tfplan   # no diff shown — applies exactly what was planned
```

This is the **CI/CD pattern**: plan in one job, apply in another, with approval in between.

### `terraform apply` notes

- Without arguments, runs a fresh plan and asks for `yes`.
- With a saved plan file, applies that exact plan.
- `-auto-approve` skips the prompt (use in CI, never interactively in prod).
- Updates state on success.

### `terraform fmt` and `terraform validate`

These should run on every commit (pre-commit hook or CI step):

- `terraform fmt -recursive` — formats all `.tf` files.
- `terraform validate` — catches `argument missing`, `wrong type`, etc.

Note: `validate` does NOT check that resources actually work in the cloud — only that the config is *internally consistent*.

## Lab — End-to-end workflow

**Goal:** practice all six commands on a real Azure resource.

1. `mkdir -p ~/tf-labs/04-workflow && cd ~/tf-labs/04-workflow`.
2. Create `main.tf`:
   ```hcl
   terraform {
     required_providers {
       azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
     }
   }
   provider "azurerm" { features {} }

   resource "azurerm_resource_group" "demo" {
     name     = "rg-workflow-demo"
     location = "eastus"
     tags = {
       env = "training"
     }
   }
   ```
3. Format it (intentionally mess up the indentation first, then fix with `fmt`):
   ```bash
   terraform fmt
   ```
4. Initialize: `terraform init`.
5. Validate: `terraform validate`. Should say "Success!".
6. Plan and save: `terraform plan -out=tfplan`. Read the diff carefully.
7. Apply saved plan: `terraform apply tfplan`.
8. Modify `main.tf` — change `env = "training"` to `env = "dev"`. Re-plan:
   ```bash
   terraform plan
   ```
   You should see a `~ update in-place`.
9. Apply: `terraform apply -auto-approve`.
10. Destroy: `terraform destroy -auto-approve`.

## Trainer notes

- Show what happens if you skip `init` and run `plan` directly — error.
- Show what happens if you delete `.terraform/` and re-run — `init` rebuilds it.
- Common exam trap: `validate` does NOT require cloud credentials; `plan` does (for refresh).
- Discussion: "Why save a plan file?" — auditability and CI/CD.

## Next

➡ [Module 5 — Variables and Outputs](05-variables-outputs.md)
⬅ [Module 3 — Providers](03-providers.md)
