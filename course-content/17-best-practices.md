# Module 17 — Best Practices

> Not a single exam objective, but covers patterns that appear across scenario questions.

## Why this matters

Knowing *what* a feature does isn't enough on real teams. The exam asks "given this scenario, which approach should you take?" — that's best-practices territory.

## Theory

### Repo structure

A common, sensible layout:

```
infra/
├── modules/                 ← your private modules
│   ├── vnet/
│   ├── aks/
│   └── postgres/
├── envs/                    ← root modules per environment
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   ├── stage/
│   └── prod/
└── README.md
```

Each env folder is its own root module with its own state. Modules are referenced by relative path or registry.

### Naming and tagging

- Use a **prefix scheme**: `<resource>-<workload>-<env>-<region>` → `vm-web-prod-eus`.
- Tag everything: `env`, `owner`, `cost_center`, `managed_by = "terraform"`.
- Use a `locals { common_tags = ... }` and `merge(local.common_tags, { ... })` in every resource.

### Pin your versions

| Pin | Where |
|---|---|
| Terraform version | `terraform { required_version = "~> 1.12" }` |
| Provider versions | `required_providers { ... version = "~> 5.80" }` |
| Module versions | `version = "~> 1.0"` (registry) or `?ref=v1.0.0` (Git) |
| Lock file | Commit `.terraform.lock.hcl` |

Without pinning, "it worked yesterday" becomes "we just broke prod because the provider released a major version."

### State per environment

One state file per environment, never one big mega-state. Reasons:

- Blast radius — a bad apply only affects one env.
- Apply speed — small state = fast plan.
- Permission boundaries — prod state can require approvals dev doesn't.

### CI/CD pattern

```
PR opened → terraform fmt + validate + plan (post comment)
PR merged → terraform apply with approval
```

In HCP Terraform this is built in. In GitHub Actions, the [github-actions-pipeline/](../github-actions-pipeline/) folder has examples.

### Use modules — but not too early

- 1 use of a pattern: copy-paste it.
- 2 uses: still copy-paste; you don't yet know which parts vary.
- 3+ uses: extract a module.

Premature modularization makes code harder to read and reason about.

### Validate inputs at the boundary

Use variable `validation` blocks (Module 13) to fail fast with a clear error message, rather than waiting for the cloud API to reject the call 30 seconds in.

### Secrets

- Never commit `.tfvars` with secrets.
- Use Vault / Key Vault / Secrets Manager.
- Prefer `ephemeral` and write-only arguments (Module 14).
- Use OIDC federation for CI → cloud auth — no long-lived secrets.

### Drift management

- Use `plan -refresh-only` periodically (or HCP drift detection).
- For attributes that legitimately drift, use `ignore_changes`.
- For autoscaled resources, ignore the autoscaling-managed attributes.

### `terraform fmt` and `validate` in pre-commit

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.96.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_tflint
```

### Linting and security scanning

- **tflint** — catches deprecated providers, unused declarations, typos.
- **tfsec** / **Checkov** / **Trivy** — security policy checks against the plan.
- **terraform-docs** — auto-generated module README tables.

### Common anti-patterns to avoid

| Anti-pattern | Better |
|---|---|
| One giant `main.tf` for everything | Split by concern: `networking.tf`, `compute.tf`, `outputs.tf` |
| Hard-coded resource IDs | References (`resource.x.id`) |
| `count` when each instance is distinct | `for_each` over a map |
| `terraform apply` on your laptop in prod | HCP Terraform or CI |
| Long-lived AWS access keys in CI | OIDC federation |
| `sensitive = true` and calling it secure | Add ephemeral/write-only |
| Skipping `terraform fmt` | Pre-commit hook |
| Committing `terraform.tfstate` | `.gitignore` it |

### Backwards compatibility

When you bump:

- **Terraform**: most upgrades are non-breaking. Major version (1.x → 2.x) may rename features.
- **Provider major version**: read the release notes; they often rename arguments.
- **Module major version**: assume breaking; pin and migrate deliberately.

## Lab — Refactor an ugly config

**Goal:** practice spotting and fixing best-practice violations.

1. `mkdir -p ~/tf-labs/17-best && cd ~/tf-labs/17-best`.
2. Save the following "smelly" `bad.tf`:
   ```hcl
   resource "azurerm_resource_group" "rg" {
     name = "myrg"
     location = "eastus"
   }
   resource "azurerm_virtual_network" "v1" {
     name = "vnet"
     address_space = ["10.0.0.0/16"]
     location = "eastus"
     resource_group_name = "myrg"
   }
   resource "azurerm_subnet" "s1" {
     name = "s1"
     resource_group_name = "myrg"
     virtual_network_name = "vnet"
     address_prefixes = ["10.0.1.0/24"]
   }
   resource "azurerm_subnet" "s2" {
     name = "s2"
     resource_group_name = "myrg"
     virtual_network_name = "vnet"
     address_prefixes = ["10.0.2.0/24"]
   }
   ```
3. Identify the issues:
   - No provider/required_providers block.
   - Hardcoded RG and VNet names everywhere.
   - No `required_version`.
   - Two near-identical subnets begging for `for_each`.
   - No tags, no naming convention.
   - No outputs.
4. Refactor into `main.tf`, `variables.tf`, `outputs.tf` using:
   - `for_each` for subnets.
   - References (no hardcoded strings).
   - Validation on the env variable.
   - Tags via `merge(local.common_tags, ...)`.
5. Compare lines of code before/after — usually fewer lines and more flexible.

## Trainer notes

- Spend time on the lab. Most students benefit more from refactoring practice than reading another list.
- Discussion: "How much best-practice tooling is too much?" — a team of three doesn't need the same setup as a team of fifty.

## Next

➡ [Exam preparation](exam-prep.md)
⬅ [Module 16 — HCP Terraform](16-hcp-terraform.md)
