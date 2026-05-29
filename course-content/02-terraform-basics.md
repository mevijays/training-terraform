# Module 2 — Terraform Basics

> **Exam objective:** Understand the purpose of Terraform and its core components.

## Why this matters

Before writing real code, you need a mental model of what Terraform actually *is* — a CLI, a state file, and a plugin system. Most "weird" Terraform behavior is explained by one of these three.

## Theory

**Terraform** is an open-source IaC tool by HashiCorp. The current version line is **1.12.x** (as of 2026), and it's what the 004 exam targets.

### The three pieces

1. **The CLI** (`terraform`) — what you run.
2. **Configuration files** (`*.tf`) — what you write, in **HCL** (HashiCorp Configuration Language).
3. **State file** (`terraform.tfstate`) — Terraform's memory of what it created.

### Analogy: a smart contractor

Imagine hiring a contractor to renovate your house:

- You give them **blueprints** (the `.tf` files — desired state).
- They keep a **logbook** of what they've built (the state file).
- Each visit, they **compare blueprints to logbook to reality** and only do the work needed (the plan/apply cycle).
- They use **specialists** — electrician, plumber — for parts of the job (providers).

If you lose the logbook, the contractor doesn't know what they built. If the blueprints and logbook disagree, they ask before changing things. That's Terraform.

### What Terraform is NOT

- ❌ A configuration management tool (use Ansible / Chef inside the VM).
- ❌ A monitoring tool.
- ❌ A package manager.
- ❌ A CI/CD tool (though it runs *in* CI/CD).

### Why state matters

The state file is how Terraform maps "this resource block in my code" → "this real resource in the cloud, with this ID". Without state, Terraform would have no way to know whether to create, update, or delete on the next run.

**Benefits of state:**

- Tracks resource metadata (IDs, attributes, dependencies).
- Enables performance — Terraform doesn't have to query every resource on every run.
- Enables collaboration via **remote state** (we cover this in Module 11).

### Installation

```bash
# macOS (Homebrew)
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Windows (Chocolatey)
choco install terraform

# Linux
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

terraform version
```

Expected output: `Terraform v1.12.x`.

## Lab — Hello, Terraform

**Goal:** initialize and apply your first config (just a local file resource — no cloud cost).

1. Create a folder:
   ```bash
   mkdir -p ~/tf-labs/02-basics && cd ~/tf-labs/02-basics
   ```
2. Create `main.tf`:
   ```hcl
   terraform {
     required_version = ">= 1.12.0"
     required_providers {
       local = {
         source  = "hashicorp/local"
         version = "~> 2.5"
       }
     }
   }

   resource "local_file" "hello" {
     filename = "${path.module}/hello.txt"
     content  = "Hello from Terraform!"
   }
   ```
3. Run the core workflow:
   ```bash
   terraform init
   terraform plan
   terraform apply -auto-approve
   ```
4. Verify: `cat hello.txt`.
5. Look at the state: `cat terraform.tfstate`. Notice it records the file's content as a managed resource.
6. Clean up: `terraform destroy -auto-approve`.

## Trainer notes

- Spend 5 min showing the `.terraform/` directory and `terraform.tfstate` — students often don't realize these are real files on disk.
- Discussion: "What happens if two engineers run `terraform apply` at the same time on the same folder?" (Spoiler: state corruption — solved by remote state + locking, Module 11.)

## Next

➡ [Module 3 — Providers](03-providers.md)
⬅ [Module 1 — IaC Fundamentals](01-iac-fundamentals.md)
