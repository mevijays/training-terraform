# Module 3 — Providers

> **Exam objective:** Understand Terraform providers — install, version, multi-provider configs, plugin architecture.

## Why this matters

Terraform itself doesn't know anything about AWS or Azure. **Providers** are the plugins that teach it. Picking the wrong version, or misconfiguring auth, is the #1 cause of "it works on my laptop" issues.

## Theory

A **provider** is a plugin that lets Terraform talk to a specific platform's API. `hashicorp/aws` talks to AWS, `hashicorp/azurerm` talks to Azure, `integrations/github` manages GitHub repos.

### Analogy: phone adapters

Terraform core is a phone. Each provider is an adapter for a different country's plug. The phone doesn't change; you just swap the adapter.

### Where providers come from

Providers live in the [Terraform Registry](https://registry.terraform.io/). They have a 3-part address:

```
<NAMESPACE>/<NAME>/<VERSION>
hashicorp/aws/5.80.0
```

Namespaces tell you who maintains it: `hashicorp/*` is official, `integrations/*` is community-with-HashiCorp-blessing, `<vendor>/*` is third-party.

### Required providers block

```hcl
terraform {
  required_version = ">= 1.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
```

The `version` constraint uses [SemVer](https://semver.org/) operators:

| Operator | Meaning |
|---|---|
| `= 5.80.0` | Exactly this version |
| `>= 5.0` | This or newer |
| `~> 5.80` | `>= 5.80, < 6.0` (pessimistic, recommended) |
| `~> 5.80.0` | `>= 5.80.0, < 5.81.0` |

### How Terraform finds and fetches providers

1. You write `required_providers`.
2. `terraform init` reads the block.
3. Terraform contacts the registry, downloads the plugin into `.terraform/providers/`.
4. A **lock file** (`.terraform.lock.hcl`) records the exact version and checksum. **Commit this file.** It guarantees teammates and CI use the same version.

### Multiple instances of the same provider (aliases)

You can run two AWS providers — one per region — using `alias`:

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

resource "aws_s3_bucket" "east" {
  bucket = "my-east-bucket"
}

resource "aws_s3_bucket" "west" {
  provider = aws.west
  bucket   = "my-west-bucket"
}
```

### Plugin architecture

Terraform core knows nothing about clouds. It does three things:

1. Parse HCL.
2. Build a graph of resources.
3. Call providers' CRUD functions (`Create`, `Read`, `Update`, `Delete`).

Providers are separate processes that Terraform talks to via gRPC. This is why upgrading the AWS provider doesn't require upgrading Terraform itself.

## Lab — Multi-cloud, two providers, one config

**Goal:** spin up one resource in Azure and one in AWS from the same Terraform folder.

1. `mkdir -p ~/tf-labs/03-providers && cd ~/tf-labs/03-providers`.
2. Authenticate to both clouds:
   ```bash
   az login
   aws configure   # or use AWS SSO
   ```
3. Create `main.tf`:
   ```hcl
   terraform {
     required_version = ">= 1.12.0"
     required_providers {
       aws     = { source = "hashicorp/aws",     version = "~> 5.80" }
       azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
     }
   }

   provider "aws" {
     region = "us-east-1"
   }

   provider "azurerm" {
     features {}
   }

   resource "azurerm_resource_group" "demo" {
     name     = "rg-multicloud-demo"
     location = "eastus"
   }

   resource "aws_s3_bucket" "demo" {
     bucket = "tf-multicloud-demo-${random_id.suffix.hex}"
   }

   resource "random_id" "suffix" {
     byte_length = 4
   }
   ```
4. Run:
   ```bash
   terraform init
   terraform plan
   terraform apply -auto-approve
   ```
5. Inspect `.terraform.lock.hcl` — it pinned both providers.
6. Verify in both clouds (Azure portal, AWS console).
7. Clean up: `terraform destroy -auto-approve`.

## Trainer notes

- Show the `.terraform/providers/` folder — students rarely peek inside.
- Discussion: "Why does HashiCorp put `~>` constraints in their own examples?" (Predictable upgrades; major versions can break.)
- Gotcha: `terraform init -upgrade` is needed to pick up new version constraints; otherwise the lock file pins you.

## Next

➡ [Module 4 — Core Workflow](04-core-workflow.md)
⬅ [Module 2 — Terraform Basics](02-terraform-basics.md)
