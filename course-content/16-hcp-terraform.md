# Module 16 — HCP Terraform (formerly Terraform Cloud)

> **Exam objective (004 NEW DOMAIN):** Understand HCP Terraform capabilities — collaboration, governance, workspaces and projects, integration.

## Why this matters

HCP Terraform is the SaaS that runs Terraform for teams. In 004 it gets its own domain — expect questions on workspaces, projects, variable sets, run triggers, policies, and the `cloud` block.

## Theory

### What HCP Terraform is

A HashiCorp-managed SaaS (also branded "HCP" for HashiCorp Cloud Platform) that:

- **Runs Terraform** in HashiCorp's infrastructure, not your laptop.
- **Stores state** centrally with locking, history, and encryption.
- **Manages variables and secrets** per workspace and across teams.
- **Enforces policies** via Sentinel or OPA.
- **Integrates with VCS** (GitHub, GitLab, Bitbucket, Azure DevOps) for plan-on-PR.

Free tier exists for small teams. Paid tiers add SSO, audit logs, drift detection, and policy.

### Workspaces vs projects

| Concept | What it is |
|---|---|
| **Workspace** | One configuration ↔ one state file. Like a folder. |
| **Project** | A grouping of workspaces, with shared variables/permissions. Like an environment-or-team boundary. |
| **Organization** | The top-level tenant (one per company). |

So: `Organization → Projects → Workspaces`.

### Three workspace execution modes

| Mode | Where plan/apply runs | When to use |
|---|---|---|
| **Remote** | In HCP Terraform | Default. CI-like; logs, history, policy. |
| **Local** | On your machine, state in HCP | Legacy/migration scenarios. |
| **Agent** | On a self-hosted runner in your network | When HCP can't reach your private cloud APIs. |

### The `cloud` block

The modern way to integrate root configurations with HCP Terraform:

```hcl
terraform {
  cloud {
    organization = "my-org"

    workspaces {
      tags = ["network", "prod"]
    }
  }
}
```

Two ways to identify workspaces:

- `name = "prod-network"` — one specific workspace.
- `tags = ["network", "prod"]` — multiple workspaces matching all listed tags (great for module reuse).

### Variables and variable sets

Each workspace can have:

- **Terraform variables** (input variables, set as plain or sensitive).
- **Environment variables** (e.g., `ARM_*`, `AWS_*`, `TF_LOG`).

**Variable sets** are reusable groups of variables that can be attached to multiple workspaces. Perfect for cloud credentials and common tags.

### Run triggers and integrations

| Capability | What it does |
|---|---|
| **VCS connection** | Plans run on PR open/update; apply on merge. |
| **Run triggers** | Workspace A applies → workspace B starts. |
| **API-driven runs** | CI uploads a config tar and triggers a run. |
| **Notifications** | Webhooks, Slack, email on run events. |
| **No-code provisioning** | Self-service catalog from registry modules. |

### Policy enforcement

Two flavors:

- **Sentinel** — HashiCorp's policy DSL.
- **OPA** — Open Policy Agent, written in Rego.

Both run between plan and apply. Three enforcement levels:

| Level | Behavior |
|---|---|
| `advisory` | Logs failures; doesn't block. |
| `soft-mandatory` | Blocks, but a privileged user can override. |
| `hard-mandatory` | Blocks, no override. |

Use cases: "no S3 buckets without encryption," "no resources outside westeurope for prod," "tag policy."

### Drift detection (paid tier)

HCP Terraform periodically refreshes workspaces against the cloud and reports drift on a dashboard — without applying anything. Pairs nicely with `check` blocks (Module 13).

### Private module/provider registry

Each org gets a private registry. Publish your internal modules with proper versioning; consumers reference them like the public registry:

```hcl
module "network" {
  source  = "app.terraform.io/my-org/network/azurerm"
  version = "1.4.0"
}
```

### Analogy: GitHub for Terraform

- Your laptop runs `terraform apply` = pushing to a local branch only you can see.
- HCP Terraform = the central GitHub, with PRs (plans on PR), reviews (policy), logs (run history), and shared secrets (variable sets).

### Collaboration and governance recap

| Goal | Feature |
|---|---|
| Single source of truth | Remote state in workspaces |
| No "works on my laptop" | Remote execution |
| Audit + history | Run logs + state versions |
| Reviewable infra changes | VCS-triggered plans on PR |
| Guardrails | Sentinel/OPA policies |
| Secret hygiene | Variable sets + sensitive flag |
| Self-service | No-code provisioning |

## Lab — Connect a workspace to a VCS and run a plan

**Goal:** create a workspace, connect to GitHub, run a plan from a PR.

> Requires a free HCP Terraform account and a GitHub account.

1. Create a GitHub repo `tf-hcp-lab`. Add this `main.tf`:
   ```hcl
   terraform {
     cloud {
       organization = "YOUR-ORG"
       workspaces {
         name = "hcp-lab"
       }
     }
     required_providers {
       random = { source = "hashicorp/random", version = "~> 3.6" }
     }
   }

   resource "random_pet" "name" {
     length = 2
   }

   output "pet" { value = random_pet.name.id }
   ```
2. In HCP Terraform UI: **Settings → Providers / VCS providers** → connect GitHub.
3. **New workspace → Version control workflow** → pick `tf-hcp-lab` → name it `hcp-lab` → Create.
4. Locally:
   ```bash
   terraform login                  # browser flow; stores token
   terraform init                   # connects to HCP
   ```
5. Open a PR that changes `length = 3`. Plan should auto-trigger in HCP Terraform. Inspect the run in the UI.
6. Merge the PR. Confirm an apply is queued; approve it in the UI.
7. Inspect:
   - **State** tab — see the state version.
   - **Variables** tab — try adding a sensitive variable.
   - **Run** tab — see logs.
8. (Optional) Create a Sentinel/OPA policy that requires `random_pet.name.length >= 2`. Re-run.
9. Destroy: from the UI use **Queue destroy plan**, or run `terraform destroy` locally.

## Trainer notes

- Show the difference between `workspaces { name = ... }` and `workspaces { tags = [...] }` — useful pattern for reusable root modules per environment.
- Common confusion: HCP Terraform workspaces are *not* the same as CLI workspaces (`terraform workspace ...`). Different concept entirely.
- Discussion: "What goes in a variable set vs a workspace variable?" — credentials/common tags → variable set; env-specific names → workspace.

## Next

➡ [Module 17 — Best Practices](17-best-practices.md)
⬅ [Module 15 — Import and CLI Tools](15-import-cli.md)
