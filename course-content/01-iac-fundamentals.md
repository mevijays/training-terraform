# Module 1 — Infrastructure as Code Fundamentals

> **Exam objective:** Understand Infrastructure as Code (IaC) concepts.

## Why this matters

You can click through a cloud portal to create one server. You cannot reliably click your way to a hundred servers across three regions and four environments without errors. IaC is how we make infrastructure repeatable.

## Theory

**Infrastructure as Code (IaC)** means writing infrastructure (networks, VMs, databases, DNS records, IAM, etc.) as text files that are version-controlled, reviewed, and applied by a tool — not by clicking in a console.

### Analogy: cooking

- **Click-ops** = cooking dinner from memory. Tastes different every time.
- **IaC** = cooking from a recipe. Anyone with the recipe gets the same dinner.

The recipe (your `.tf` file) is what we version, review, and improve over time. The dinner (your cloud environment) is just what the recipe produces.

### Advantages of IaC

| Benefit | What it means |
|---|---|
| **Repeatable** | Same code → same infra. Dev and prod look alike. |
| **Versioned** | Git history shows who changed what, when, and why. |
| **Reviewable** | Pull requests let teammates catch mistakes before they hit prod. |
| **Reusable** | Modules let you stamp out the same pattern N times. |
| **Disposable** | You can destroy and re-create environments in minutes. |
| **Documented by default** | The code *is* the documentation. |

### Declarative vs imperative

- **Declarative** (Terraform): you say *what* you want. "I want one VM named web-1." Terraform figures out *how*.
- **Imperative** (shell scripts): you say *how*. "Run `az vm create ...`, then if it fails, retry, then..."

Terraform is declarative. You describe the desired state; Terraform diffs that against reality and makes them match.

### Where Terraform fits among IaC tools

| Tool | Scope | Style |
|---|---|---|
| **Terraform** | Multi-cloud, multi-service | Declarative, stateful |
| **CloudFormation** | AWS only | Declarative, stateful (managed by AWS) |
| **ARM / Bicep** | Azure only | Declarative |
| **Pulumi** | Multi-cloud | Declarative, real programming languages |
| **Ansible / Chef / Puppet** | Configuration management (inside servers) | Mostly imperative |

Terraform's killer feature: it is **multi-cloud and service-agnostic**. The same workflow (`init` → `plan` → `apply`) works for AWS, Azure, GCP, GitHub, Datadog, Cloudflare, Snowflake, and ~3,000 other providers.

## Lab — Your first IaC artifact (no Terraform yet)

**Goal:** feel the difference between click-ops and code by listing resources before/after.

1. Log into the Azure portal. Click **Create a resource → Resource group**. Name it `rg-iac-demo`, region `eastus`. Click Create.
2. Note the steps you just took. Could a teammate reproduce them without sitting next to you?
3. Open a terminal and run:
   ```bash
   az group show --name rg-iac-demo --output yaml > rg-iac-demo.yaml
   ```
4. Open `rg-iac-demo.yaml`. **This file is IaC** — a textual representation of a real resource. If you committed it to git, you'd have a versioned, auditable history.
5. Delete the resource group from the portal: `az group delete --name rg-iac-demo --yes`.
6. Now imagine doing steps 1-5 for fifty resource groups across four subscriptions. That's the problem IaC solves.

## Trainer notes

- Open with a war story: a manual change to prod that nobody documented.
- Ask: "How does your team currently record infra changes today?" Usually answer is "tribal knowledge" or "tickets".
- Common student question: "Isn't this just YAML for cloud?" — Yes, conceptually, with a planner and state engine on top.

## Next

➡ [Module 2 — Terraform Basics](02-terraform-basics.md)
⬅ [Course index](README.md)
