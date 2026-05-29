# Exam Preparation — HashiCorp Terraform Associate (004)

## The exam at a glance

| Field | Value |
|---|---|
| Code | HCTA0-004 |
| Format | Multiple choice, online proctored (Certiverse) |
| Duration | 60 minutes |
| Question count | ~57 |
| Passing score | ~70% (40/57) |
| Validity | 2 years |
| Cost | $70.50 USD + tax |
| Language | English |

## Objectives coverage map

| # | Objective | Course module(s) |
|---|---|---|
| 1 | IaC concepts with Terraform | [01](01-iac-fundamentals.md) |
| 2 | Terraform fundamentals (install, providers, state intro) | [02](02-terraform-basics.md), [03](03-providers.md) |
| 3 | Core workflow | [04](04-core-workflow.md) |
| 4 | Configuration (variables, outputs, expressions, deps, validation, secrets) | [05](05-variables-outputs.md), [06](06-resources-data.md), [07](07-expressions-functions.md), [08](08-dependencies-lifecycle.md), [13](13-custom-validation-checks.md), [14](14-sensitive-data-vault.md) |
| 5 | Modules | [09](09-modules.md) |
| 6 | State management | [10](10-state-management.md), [11](11-remote-state-locking.md), [12](12-state-drift-refactor.md) |
| 7 | Maintain infrastructure | [15](15-import-cli.md) |
| 8 | HCP Terraform | [16](16-hcp-terraform.md) |
| 9 | Best practices | [17](17-best-practices.md) |

## Two-week study plan

### Week 1 — Foundations
- **Day 1:** Modules 1, 2, 3
- **Day 2:** Module 4 — repeat the full workflow lab three times
- **Day 3:** Modules 5, 6
- **Day 4:** Modules 7, 8
- **Day 5:** Module 9 — write your own module from scratch (not just the lab)

### Week 2 — Advanced + practice
- **Day 6:** Modules 10, 11
- **Day 7:** Module 12 — the `moved`/`removed` lab is exam-critical
- **Day 8:** Modules 13, 14 — the new validation + ephemeral material is heavy
- **Day 9:** Module 15
- **Day 10:** Module 16 — get an HCP Terraform account; do the VCS lab
- **Day 11:** Module 17, then attempt the [capstone project](../project/README.md)
- **Day 12-13:** Practice exams (links below)
- **Day 14:** Final review of weak topics; take the exam

## Things the exam definitely tests

- The exact behavior and order of `init`, `validate`, `plan`, `apply`, `destroy`, `fmt`.
- What goes in state and what doesn't.
- The difference between `resource` and `data`.
- `count` vs `for_each` — and `each.key` / `each.value` / `count.index`.
- Variable types — `list`, `set`, `map`, `object`, `tuple`.
- Source addressing for modules (registry vs Git vs local).
- Backend types and which support locking.
- `moved` blocks and `removed` blocks.
- `validation` (variable), `precondition`/`postcondition` (lifecycle), `check` (top-level).
- Lifecycle: `create_before_destroy`, `prevent_destroy`, `ignore_changes`, `replace_triggered_by`.
- HCP Terraform: workspaces, projects, variable sets, run triggers, policy enforcement levels, the `cloud` block.

## Common trap questions

| Trap | Reality |
|---|---|
| "What does `terraform validate` need to connect to?" | Nothing. It's offline. |
| "What does `terraform plan` need?" | Provider credentials (for refresh). |
| "Where do variables come from when applying?" | Default → env (`TF_VAR_*`) → tfvars → `-var-file` → `-var` (highest wins). |
| "Can `backend` use variables?" | No. Use partial config + `-backend-config`. |
| "Where do `version =` and `?ref=` apply?" | `version` only for registry. `?ref=` only for Git sources. |
| "Does `sensitive = true` encrypt state?" | No — only redacts CLI output. |
| "Is `terraform refresh` still the way to refresh?" | No — use `terraform apply -refresh-only`. |
| "What's the difference between HCP Terraform workspaces and CLI workspaces?" | Different concepts entirely. CLI workspaces are local-state alternates. |

## Practice resources

- Official: https://developer.hashicorp.com/terraform/tutorials/certification-004
- Sample questions: https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-questions
- Bryan Krausen's practice exam course (Udemy) — frequently updated for 004.
- ITechSchool / Whizlabs / Tutorials Dojo — multiple practice tests.

## Day-of-exam tips

- Pre-check: webcam, mic, photo ID, quiet room — Certiverse will scan your room.
- Read every option before answering — distractors often contain *almost* the right command.
- Mark and move on — there's plenty of time to come back.
- Watch for "select all that apply" — partial credit usually does NOT exist.
- If you're unsure, eliminate impossibilities first.

## After passing

- Your badge appears in the HashiCorp Credential portal.
- Share on LinkedIn — recruiters search this badge.
- Next certs in the HashiCorp track: **Terraform Authoring & Operations Professional**, **Vault Associate**, **Consul Associate**.

## Navigation

- ⬅ [Module 17 — Best Practices](17-best-practices.md)
- ⬅ [Course index](README.md)
- 🎯 [Capstone project](../project/README.md)
- 🤖 [GenAI for Terraform engineers](../genai/README.md)
