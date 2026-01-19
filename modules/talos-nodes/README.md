# Talos Nodes Module

This Terraform module creates groups of Talos Linux VMs on XCP-ng using the Vates XenOrchestra provider.

## Features

- **UEFI with Secure Boot**: All VMs use UEFI firmware for security
- **Dual Network**: Each VM gets two vNICs (Kubernetes and SAN networks)
- **Random Hex IDs**: VM names use 3-character hex suffixes for uniqueness
- **Flexible Resources**: Configurable CPU, memory, and disk per group
- **Talos-Ready**: Optimized for Talos Linux clusters

## Usage

```hcl
module "talos_controlplane" {
  source = "./modules/talos-nodes"

  vm_count        = 3
  vm_name_prefix  = "talos-cntrl"
  cpus           = 4
  memory_gb      = 8
  disk_gb        = 64
  node_type      = "controlplane"
  
  template_name  = var.template_name
  net_kub_name   = var.net_kub_name
  net_san_name   = var.net_san_name
  sr_name        = var.sr_name
  
  additional_tags = ["control-plane"]
}
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `vm_count` | Number of VMs to create | `number` | `3` |
| `vm_name_prefix` | Prefix for VM names | `string` | `"talos-"` |
| `cpus` | Number of CPU cores per VM | `number` | `4` |
| `memory_gb` | Memory in GB per VM | `number` | `8` |
| `disk_gb` | Disk size in GB per VM | `number` | `64` |
| `node_type` | Type of Talos node | `string` | `"worker"` |
| `template_name` | XCP-ng template name | `string` | Required |
| `net_kub_name` | Kubernetes network name | `string` | Required |
| `net_san_name` | SAN network name | `string` | Required |
| `sr_name` | Storage repository name | `string` | Required |
| `additional_tags` | Additional tags for VMs | `list(string)` | `[]` |
| `enable_gpu` | Enable GPU passthrough for VMs (currently for tagging only) | `bool` | `false` |
| `gpu_groups` | List of GPU group IDs to attach (reserved for future use) | `list(string)` | `[]` |
| `gpu_group_name` | Name of GPU group to lookup (reserved for future use) | `string` | `""` |

## Outputs

| Name | Description |
|------|-------------|
| `vms` | Complete VM information map |
| `vm_ids` | List of VM IDs |
| `vm_names` | List of VM names |
| `vm_primary_ips` | Map of VM names to primary IPs |

## VM Naming

VMs are named using the pattern: `{prefix}{3-char-hex-id}`

Examples:
- `talos-cntrl2f8`
- `talos-worka4d`
- `talos-stor9c3`

## Networks

Each VM gets two network interfaces:
1. **Kubernetes Network**: Primary interface for cluster communication
2. **SAN Network**: Secondary interface for storage traffic

## GPU Support

**Current Status**: The xenorchestra Terraform provider doesn't currently support GPU passthrough configuration. 

**Workaround**: 
1. Create VMs with `enable_gpu = true` (this adds GPU-related tags)
2. Manually assign GPUs via XenOrchestra UI after VM creation
3. The GPU variables are reserved for future provider support

## Getting IP Addresses

After `terraform apply`, run `terraform refresh` to populate IP addresses, then view with:

```bash
terraform output controlplane_nodes
terraform output worker_nodes
terraform output all_nodes_summary
```