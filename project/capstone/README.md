# NovaPay Capstone — Reference Solution

This folder contains a **working reference solution** for the [NovaPay capstone](../README.md). Use it to compare against your own attempt, or as a starting point.

> ⚠️ This is a **teaching solution**. It's deliberately simplified for clarity and free-tier friendliness. A real production deployment would add: VNet integration, private endpoints everywhere, customer-managed keys, full RBAC, runbooks, etc.

## Structure

```
capstone/
├── modules/
│   ├── azure-network/    # VNet + subnets + NSG
│   ├── azure-vm/         # Linux VM with cloud-init
│   ├── azure-keyvault/   # Key Vault + sample secret
│   ├── aws-static-site/  # S3 + CloudFront + Route53
│   └── observability/    # Log Analytics + diagnostic settings
├── envs/
│   ├── dev/              # dev environment root config
│   ├── stage/
│   └── prod/
└── policy/
    └── novapay-tags.sentinel
```

## What it provisions per env

| Resource | Service |
|---|---|
| Resource group | Azure |
| VNet + 3 subnets | Azure |
| NSG | Azure |
| Key Vault with generated DB password | Azure |
| 1 Linux web VM | Azure |
| Log Analytics workspace + diagnostic settings | Azure |
| S3 bucket + CloudFront static site | AWS |

## Prerequisites

1. Azure subscription, `az login` works.
2. AWS account, `aws sts get-caller-identity` works.
3. Terraform 1.12+.
4. (Optional) HCP Terraform org with three workspaces tagged `dev`, `stage`, `prod`.

## How to run (local backend, dev env)

```bash
cd envs/dev
terraform init
terraform plan -out=tfplan
terraform apply tfplan
# inspect outputs
terraform output

# tear down
terraform destroy
```

## How to run (HCP Terraform)

1. Create workspaces `novapay-dev`, `novapay-stage`, `novapay-prod` in your org, tagged with the env.
2. Edit `envs/<env>/backend.tf` and set `organization`.
3. Add a variable set with `ARM_*` and `AWS_*` credentials (or use OIDC).
4. Push a PR that touches `envs/dev/`; plan runs in HCP.
5. Merge → apply runs (with approval if configured).

## Mapping back to the capstone phases

| Phase | Where it lives |
|---|---|
| 1. Bootstrap | `envs/*/backend.tf` |
| 2. Networking module | `modules/azure-network/` |
| 3. Secrets + Key Vault | `modules/azure-keyvault/` + `envs/*/main.tf` |
| 4. Compute | `modules/azure-vm/` |
| 5. AWS static site | `modules/aws-static-site/` |
| 6. Observability | `modules/observability/` |
| 7. Refactor with `moved` | example in `envs/dev/moved.tf` |
| 8. Policy | `policy/novapay-tags.sentinel` |
| 9. Promote envs | `envs/{dev,stage,prod}/` |

## Cost note

Apply dev only and immediately `destroy` after testing. The whole stack is < $5 for a few hours; left running 24/7 it's ~$30/month.

## Where to extend (homework)

The solution stops at acceptance criteria. Stretch goals from the [project README](../README.md) are exercises for you:

- Add a second AWS region with a provider alias.
- Migrate the VM module to `for_each` over `var.vms`.
- Add tfsec + tflint to a GitHub Actions pre-PR check.

## Navigation

- ⬅ [Project description](../README.md)
- ⬅ [Course content](../../course-content/README.md)
- ⬅ [Repo README](../../README.md)
