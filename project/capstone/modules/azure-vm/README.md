# Module: azure-vm

A small Ubuntu Linux VM with cloud-init that installs nginx and shows a hello page on port 80. Demonstrates `lifecycle { ignore_changes }` for `custom_data` so re-runs don't replace the VM.

## Usage

```hcl
module "vm" {
  source                = "../../modules/azure-vm"
  name                  = "novapay-dev"
  resource_group_name   = azurerm_resource_group.this.name
  location              = azurerm_resource_group.this.location
  subnet_id             = module.network.subnet_ids["web"]
  admin_ssh_public_key  = file("~/.ssh/id_rsa.pub")
  size                  = "Standard_B1s"
  tags                  = local.common_tags
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | string | — | Base name (e.g., `novapay-dev`) |
| `resource_group_name` | string | — | RG |
| `location` | string | — | Azure region |
| `subnet_id` | string | — | Subnet to attach NIC to |
| `size` | string | `Standard_B1s` | VM SKU |
| `admin_username` | string | `novapay` | Admin user |
| `admin_ssh_public_key` | string | — | Public key contents |
| `tags` | map(string) | `{}` | Tags |

## Outputs

| Name | Description |
|---|---|
| `id` | VM resource ID |
| `name` | VM name |
| `private_ip` | NIC private IP |

## Notes

- No public IP — connect via Bastion or jumpbox.
- `lifecycle { ignore_changes = [custom_data] }` prevents re-runs from replacing the VM if you edit the script.
