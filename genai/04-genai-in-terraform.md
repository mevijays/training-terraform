# 4 — GenAI in Terraform Workflows

How to actually use AI coding agents day-to-day on a Terraform codebase, with examples you can copy.

## Use case 1 — Drafting a new module

**Prompt to your agent:**

> Look at the existing modules in `modules/`. Notice the conventions for variable naming (`snake_case`), required outputs (`id`, `name`, plus per-resource attributes), validations on `env` and `location`, and the use of `local.common_tags`. Create a new module `modules/azure-postgres` for an Azure Database for PostgreSQL Flexible Server, following the same conventions. It should take `env`, `location`, `resource_group_name`, `subnet_id`, `db_password_kv_secret_id` and output `fqdn`, `id`, `name`.

The agent will read `modules/azure-network/` and `modules/azure-vm/` to learn your conventions, then produce a consistent new module.

**What you do next:** review the output. Common things to check:

- Does it pin provider versions correctly?
- Are SKUs realistic and within free-tier where relevant?
- Are required variables actually required (no surprise defaults)?
- Does it handle the `sensitive`/`ephemeral` arguments you're using?

## Use case 2 — Reviewing a teammate's PR

**Prompt:**

> Read the diff in this PR (`gh pr diff 123`). Identify any of: hardcoded values that should be variables, missing validations, missing tags, anti-patterns from our [best practices module](../course-content/17-best-practices.md), and security concerns (public buckets, missing encryption, weak NSG rules).

The agent does in 30 seconds what would take 20 minutes by hand. **You still approve or reject.**

## Use case 3 — Generating tests

Use [Terratest](https://terratest.gruntwork.io/) (Go) or [`terraform test`](https://developer.hashicorp.com/terraform/cli/commands/test) (1.6+, built-in).

**Prompt:**

> Generate `terraform test` cases for `modules/azure-network`. Cover: defaults work, invalid CIDR fails the variable validation, `for_each` over subnets produces the right number of resources, and the `tags` are merged correctly.

You get a starter test file. Run, iterate, commit.

## Use case 4 — Understanding a forced replacement

```bash
terraform plan -out=tfplan
terraform show -json tfplan > plan.json
```

**Prompt:**

> Read `plan.json`. For every resource being replaced (`-/+`), identify which attribute change forced the replacement. Look at the provider docs to confirm. For each one, recommend whether we should let it proceed, use `create_before_destroy`, or change the code to avoid replacement.

Saves you from `jq`-ing through 200KB of JSON manually.

## Use case 5 — Drift narrative

You ran `terraform plan -refresh-only` and got 47 changes back.

**Prompt:**

> Summarize the drift in this plan. Group by: (a) drift the autoscaler/cluster manager is responsible for and that we should `ignore_changes`, (b) drift from manual portal edits that should be reconciled back, (c) drift that might indicate a security incident.

## Use case 6 — Documentation

**Prompt:**

> For every module in `modules/`, generate a README that includes: a one-paragraph summary, a usage example, a table of inputs, a table of outputs, and a section on supported provider versions. Use the existing README in `modules/azure-network/` as the template.

This is what `terraform-docs` does, but with better prose.

## Use case 7 — Migrating between providers / clouds

**Prompt:**

> Read `modules/azure-static-site/`. Produce an equivalent `modules/aws-static-site/` that uses S3 + CloudFront + Route53 instead of Storage Account + Front Door + Azure DNS. Preserve the input/output shape as much as possible.

The agent reads provider docs for both sides and produces a translation. **Review the security model carefully** — the agent doesn't always know your org's required encryption settings.

## Use case 8 — Onboarding

A new engineer joins. They open the repo. The agent (with a good `CLAUDE.md` or Cursor Rules file at the repo root) can explain:

- What each top-level folder does.
- The conventions the team follows.
- Which environments exist and how to deploy to them.
- The "golden path" for adding a new resource.

Some teams keep their internal "platform docs" as Markdown inside the repo specifically so the agent can read them.

## Setting up the agent for success

A short list of files that make agents dramatically more useful in a Terraform repo:

1. **`CLAUDE.md`** (or `.cursorrules`, or `AGENTS.md`) at the repo root with:
   - Folder layout
   - Naming conventions
   - Where state lives
   - "Don't run `terraform destroy` without explicit confirmation"
   - Links to runbooks
2. **`README.md`** in every module with input/output tables.
3. **Pre-commit hooks** that run `terraform fmt`, `validate`, `tflint`, `tfsec` — agents will pick these up and self-correct.
4. **`docs/`** folder with architecture diagrams and decisions (ADRs) — these become RAG fodder for the agent.

## What NOT to do

- **Don't blindly accept** an agent-written `terraform apply`. Always read the plan.
- **Don't paste secrets** into a public/chat-style agent. Use the enterprise/private versions, or strip the value first.
- **Don't let the agent edit prod state** without a human in the loop.
- **Don't disable `prevent_destroy`** because the agent told you to. Stop and ask why.

## A worked example session

```
You: Our prod environment's apply is failing. Look at the latest run in HCP Terraform
     (here's the URL) and tell me why.

Agent: Fetches the run page. The plan succeeded; apply failed during the
       azurerm_key_vault.prod resource. The error is "AuthorizationFailed: The user
       does not have authorization to perform action
       Microsoft.KeyVault/vaults/write." Looking at the workspace's Azure SP, it
       has Contributor on the subscription but Key Vault was moved under a
       management group last week that requires explicit Key Vault Administrator.
       Recommended fix: add the SP to the Key Vault Administrators role on the new
       management group. Want me to draft the role assignment Terraform?

You: Yes, but as a separate workspace — that workspace is admin-bootstrap and
     should own this.

Agent: Drafts the role assignment in `envs/admin/main.tf`, opens a PR.

You: (Review, approve, merge.) HCP Terraform applies admin → role exists → re-run
     prod workspace → apply succeeds.
```

That's the loop.

## Navigation

- ⬅ [Module 3 — Coding Agents Overview](03-coding-agents-overview.md)
- ⬅ [GenAI index](README.md)
- 🎯 [Capstone project](../project/README.md)
- 📚 [Course content](../course-content/README.md)
