# HashiCorp Certified: Terraform Associate (004) — Training Curriculum

A complete, self-paced training curriculum for the **HashiCorp Certified: Terraform Associate (004)** exam, launched **January 8, 2026** (replacing the retired 003 exam). All content is aligned to Terraform **1.12.x** and **HCP Terraform** (formerly Terraform Cloud).

This repo is for both **students** (to learn) and **trainers** (to teach). Every topic has theory with analogies, a hands-on lab, and links to the next topic.

---

## Quick links

| Resource | Link |
|---|---|
| Official Exam Content List (004) | https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-review-004 |
| Official Learning Path (004) | https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-study-004 |
| Exam Review (003 → 004 changes) | [Exam-update-004.md](Exam-update-004.md) |
| Exam table (objectives) | [exam-and-toc.md](exam-and-toc.md) |
| Course content (start here) | [course-content/README.md](course-content/README.md) |
| Capstone project | [project/README.md](project/README.md) |
| GenAI for Terraform engineers | [genai/README.md](genai/README.md) |

---

## Exam at a glance

| Field | Value |
|---|---|
| Exam code | HCTA0-004 |
| Format | Multiple choice, online proctored (Certiverse) |
| Duration | 60 minutes |
| Questions | 57 |
| Passing score | ~70% |
| Validity | 2 years |
| Price | $70.50 USD + tax |

---

## What's new in 004 (vs 003)

1. **Lifecycle rules** as a named topic — `depends_on`, `create_before_destroy`, `prevent_destroy`, `ignore_changes`.
2. **Custom condition validation** — `validation`, `precondition`, `postcondition`, `check` blocks.
3. **Ephemeral values and write-only arguments** (Terraform 1.10+).
4. **HCP Terraform workspaces and projects** is its own dedicated domain.
5. **Vault + sensitive data** is explicit and tested.
6. **State drift, refactor, refresh-only, moved, removed** are explicit subtopics.

---

## Curriculum (latest 2026 objectives)

The official 9 exam objectives, mapped to course modules:

| # | Objective | Module |
|---|---|---|
| 1 | IaC concepts with Terraform | [01-iac-fundamentals.md](course-content/01-iac-fundamentals.md) |
| 2 | Terraform fundamentals (install, providers, state intro) | [02-terraform-basics.md](course-content/02-terraform-basics.md), [03-providers.md](course-content/03-providers.md) |
| 3 | Core workflow (init, validate, plan, apply, destroy, fmt) | [04-core-workflow.md](course-content/04-core-workflow.md) |
| 4 | Configuration (variables, outputs, expressions, functions, deps, validation, secrets) | [05-variables-outputs.md](course-content/05-variables-outputs.md), [06-resources-data.md](course-content/06-resources-data.md), [07-expressions-functions.md](course-content/07-expressions-functions.md), [08-dependencies-lifecycle.md](course-content/08-dependencies-lifecycle.md), [13-custom-validation-checks.md](course-content/13-custom-validation-checks.md), [14-sensitive-data-vault.md](course-content/14-sensitive-data-vault.md) |
| 5 | Modules (source, scope, version, inputs/outputs) | [09-modules.md](course-content/09-modules.md) |
| 6 | State management (backend, locking, remote, drift, refactor) | [10-state-management.md](course-content/10-state-management.md), [11-remote-state-locking.md](course-content/11-remote-state-locking.md), [12-state-drift-refactor.md](course-content/12-state-drift-refactor.md) |
| 7 | Maintain infrastructure (import, inspect state, verbose logging) | [15-import-cli.md](course-content/15-import-cli.md) |
| 8 | HCP Terraform (collaboration, governance, workspaces, projects) | [16-hcp-terraform.md](course-content/16-hcp-terraform.md) |
| 9 | Best practices & exam prep | [17-best-practices.md](course-content/17-best-practices.md), [exam-prep.md](course-content/exam-prep.md) |

---

## How to use this repo

**Students** — work through [course-content/](course-content/) in order. Each module has theory (with analogies), a hands-on lab, and a link to the next topic. After finishing all modules, work the [capstone project](project/README.md).

**Trainers** — each module is a ~45-60 min session: 20 min theory walk-through, 25-35 min lab. Use the "Trainer notes" section at the end of each module for discussion prompts and common student pitfalls.

**Cloud accounts** — labs use **Azure** and **AWS** free-tier accounts (multi-cloud, since 004 is provider-agnostic). Where possible, AWS variants are shown alongside the Azure version.

---

## Prerequisites

- A laptop with internet access
- A free Azure account: https://azure.microsoft.com/en-us/free/
- A free AWS account: https://aws.amazon.com/free/
- Terraform CLI 1.12+ installed: https://developer.hashicorp.com/terraform/install
- Azure CLI: https://learn.microsoft.com/cli/azure/install-azure-cli
- AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
- A code editor (VS Code recommended) with HashiCorp Terraform extension
- A free [HCP Terraform](https://app.terraform.io) account

---

## Repository structure

```
training-terraform/
├── README.md                ← you are here
├── exam-and-toc.md          ← exam table and objectives
├── Exam-update-004.md       ← 003 vs 004 comparison
├── course-content/          ← 17 modules + exam prep
├── project/                 ← capstone project
└── genai/                   ← GenAI concepts and AI coding agents for Terraform
```

Legacy code samples remain in `classes/`, `contents/`, `tf-cloud/`, `azure-pipelines/`, `github-actions-pipeline/`, `gitlab-ci/`, and `jenkins/` — these are referenced from the relevant course modules as working examples.

---

## License & contributions

MIT license. PRs and issues welcome. If you find a topic that's stale relative to the official HashiCorp exam page, please open an issue.
