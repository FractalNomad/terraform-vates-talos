# Output all VM information
output "vms" {
  description = "Complete VM information including names, IPs, networks, and details"
  value = {
    for vm in xenorchestra_vm.vms : vm.name_label => {
      id          = vm.id
      name        = vm.name_label
      primary_ip  = length(vm.ipv4_addresses) > 0 ? vm.ipv4_addresses[0] : "No IP assigned"
      all_ipv4    = vm.ipv4_addresses
      all_ipv6    = vm.ipv6_addresses
      power_state = vm.power_state
      cpus        = vm.cpus
      memory_max  = vm.memory_max
      networks = {
        kubernetes = var.net_kub_name
        san        = var.net_san_name
      }
      tags          = vm.tags
      template_used = var.template_name
      storage_repo  = var.sr_name
      node_type     = var.node_type
      gpu_enabled   = var.enable_gpu
      gpu_groups    = var.enable_gpu ? var.gpu_groups : []
    }
  }
}

# Output VM IDs for other modules to reference
output "vm_ids" {
  description = "List of VM IDs"
  value       = xenorchestra_vm.vms[*].id
}

# Output VM names for reference
output "vm_names" {
  description = "List of VM names"
  value       = xenorchestra_vm.vms[*].name_label
}

# Output primary IP addresses
output "vm_primary_ips" {
  description = "Primary IP addresses of VMs"
  value = {
    for vm in xenorchestra_vm.vms : vm.name_label => length(vm.ipv4_addresses) > 0 ? vm.ipv4_addresses[0] : "No IP assigned"
  }
}