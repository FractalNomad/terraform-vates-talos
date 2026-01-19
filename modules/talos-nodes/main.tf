terraform {
  required_providers {
    xenorchestra = {
      source = "vatesfr/xenorchestra"
    }
  }
}

# Data sources to get existing resources
data "xenorchestra_template" "vm_template" {
  name_label = var.template_name
}

data "xenorchestra_network" "kub_network" {
  name_label = var.net_kub_name
}

data "xenorchestra_network" "san_network" {
  name_label = var.net_san_name
}

data "xenorchestra_sr" "vm_storage" {
  name_label = var.sr_name
}

# Create VMs
resource "xenorchestra_vm" "vms" {
  count = var.vm_count

  memory_max = var.memory_gb * 1024 * 1024 * 1024 # Convert GB to bytes
  cpus       = var.cpus
  name_label = "${var.vm_name_prefix}${substr(sha256("${var.vm_name_prefix}-${count.index}"), 0, 3)}"

  template = data.xenorchestra_template.vm_template.id

  lifecycle {
    ignore_changes = [
      network[0].expected_ip_cidr,
      network[1].expected_ip_cidr
    ]
  }

  # Enable UEFI and Secure Boot
  hvm_boot_firmware = "uefi"
  auto_poweron      = var.auto_poweron
  power_state       = var.power_state

  network {
    network_id       = data.xenorchestra_network.kub_network.id
    expected_ip_cidr = var.expected_ip_cidr != "" ? var.expected_ip_cidr : null
  }

  network {
    network_id = data.xenorchestra_network.san_network.id
  }

  disk {
    sr_id      = data.xenorchestra_sr.vm_storage.id
    name_label = "vdi-01-${var.vm_name_prefix}${substr(sha256("${var.vm_name_prefix}-${count.index}"), 0, 3)}-os"
    size       = var.disk_gb * 1024 * 1024 * 1024 # Convert GB to bytes
  }

  tags = concat([
    "terraform",
    
    "talos",
    var.node_type
  ], var.enable_gpu ? concat(var.additional_tags, ["gpu-enabled"]) : var.additional_tags)
}