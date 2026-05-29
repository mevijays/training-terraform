# Module 11 — Remote State and Locking

> **Exam objective:** Describe state locking, backend block, remote state options, cloud integration auth.

## Why this matters

The minute you have two engineers working on the same Terraform, you need remote state. Without it, two applies can produce a corrupted state that takes hours to repair.

## Theory

### What "remote state" means

Instead of `terraform.tfstate` on your laptop, the state lives in a shared store: an Azure storage container, an S3 bucket, GCS, HCP Terraform, etc. All teammates and CI runners read/write that same store.

### What "locking" means

Before any read-modify-write of state, Terraform acquires a **lock** on the backend. While that lock is held, anyone else's `apply` waits or fails fast. When the lock is released, the next person proceeds.

### Analogy: Google Docs vs. emailing a Word file

- Local backend = email the Word file to your team. People edit copies; merging is a nightmare.
- Remote state with locking = Google Docs. One canonical version, and edits are coordinated.

### The `backend` block

You declare a backend inside `terraform { }`:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatevijay"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
```

Important rules:

1. **No variables** are allowed inside a `backend` block (HCL is evaluated before vars exist).
2. You use **partial configuration** + `-backend-config` for env-specific values:
   ```bash
   terraform init -backend-config="key=prod.tfstate"
   ```
3. Switching backends? `terraform init` will prompt to **migrate state**.

### Backends that support locking

| Backend | Locking mechanism |
|---|---|
| `azurerm` | Blob lease |
| `s3` | DynamoDB table (or native S3 conditional writes in newer setups) |
| `gcs` | Native object metadata |
| `remote` / `cloud` (HCP Terraform) | Built-in |
| `local` | File lock (single-machine only) |
| `consul`, `etcd3`, `pg` | Native |
| `http` (custom) | Implementation-defined |

If you ever need to break a stuck lock, use `terraform force-unlock <LOCK_ID>` — but only after confirming no one else is running.

### `cloud` block (HCP Terraform integration)

Newer than `backend "remote"` and the preferred way to integrate with HCP Terraform:

```hcl
terraform {
  cloud {
    organization = "my-org"

    workspaces {
      name = "prod-network"
    }
  }
}
```

This block enables **remote operations** — `plan`/`apply` run in HCP Terraform's environment, not your laptop. That gives you policy enforcement (Sentinel/OPA), audit logs, and shared variables.

### Authentication to backends

| Backend | Auth options |
|---|---|
| `azurerm` | Azure CLI session (`az login`), Service Principal env vars, MSI, OIDC |
| `s3` | AWS CLI profile, env vars, IAM role on EC2/EKS, OIDC from GitHub Actions |
| `gcs` | gcloud session, service account JSON, workload identity |
| `cloud` / HCP | API token via `terraform login` or `TF_TOKEN_*` env var |

For CI/CD, **OIDC federation** is the modern best practice — no long-lived secrets.

### Reading remote state from another config

```hcl
data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatevijay"
    container_name       = "tfstate"
    key                  = "network.terraform.tfstate"
  }
}

resource "azurerm_subnet" "extra" {
  virtual_network_name = data.terraform_remote_state.network.outputs.vnet_name
  # ...
}
```

This lets you split infrastructure into multiple state files (per stack/layer) while still sharing data.

## Lab — Migrate from local to Azure remote backend

**Goal:** stand up an Azure backend; migrate state into it.

1. Create the backend resources in Azure (do this once, with the CLI, not Terraform — chicken-and-egg):
   ```bash
   RG=tfstate-rg
   SA=tfstatedemo$RANDOM
   az group create -n $RG -l eastus
   az storage account create -n $SA -g $RG -l eastus --sku Standard_LRS \
     --encryption-services blob --min-tls-version TLS1_2
   az storage container create --name tfstate --account-name $SA --auth-mode login
   echo "Storage account: $SA"
   ```
2. New project folder:
   ```bash
   mkdir -p ~/tf-labs/11-remote-state && cd ~/tf-labs/11-remote-state
   ```
3. Create `main.tf` (local backend at first — no `backend` block):
   ```hcl
   terraform {
     required_providers {
       azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
     }
   }
   provider "azurerm" { features {} }

   resource "azurerm_resource_group" "demo" {
     name     = "rg-remote-state-lab"
     location = "eastus"
   }
   ```
4. `terraform init && terraform apply -auto-approve`. State is local.
5. Add the backend block:
   ```hcl
   terraform {
     backend "azurerm" {
       resource_group_name  = "tfstate-rg"
       storage_account_name = "tfstatedemoXXXXX"   # use your $SA from step 1
       container_name       = "tfstate"
       key                  = "lab11.tfstate"
     }
     # required_providers ...
   }
   ```
6. Re-init: `terraform init`. It will ask **"Do you want to migrate state?"** → yes.
7. Inspect the storage container in the portal — you'll see `lab11.tfstate`.
8. Open two terminals. In #1, run `terraform plan` and wait. In #2 (same folder), run `terraform plan`. Second should report **lock held**.
9. Destroy.
10. Clean up backend (optional): `az group delete -n tfstate-rg --yes`.

## Trainer notes

- Show the lock blob in Azure portal — students like seeing the proof.
- Talk through OIDC for CI/CD as the "next step" but don't lab it here (the [terraform/github/](../terraform/github/) folder has examples for AWS+GitHub OIDC if you want a deep dive).
- Exam trap: variables/locals **cannot** be used inside the `backend` block. Use partial config and `-backend-config=...` flags or files.

## Next

➡ [Module 12 — State Drift, Refactor, Moved, Removed](12-state-drift-refactor.md)
⬅ [Module 10 — State Management Basics](10-state-management.md)
