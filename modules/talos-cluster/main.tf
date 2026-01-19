terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.9"
    }
  }
}

resource "talos_machine_secrets" "machine_secrets" {
  talos_version = var.talos_version
}

data "talos_machine_configuration" "controlplane" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = var.cluster_endpoint
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.machine_secrets.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  config_patches     = var.controlplane_config_patches
  docs               = false
  examples           = false
}

data "talos_machine_configuration" "worker" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = var.cluster_endpoint
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.machine_secrets.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  config_patches     = var.worker_config_patches
  docs               = false
  examples           = false
}

data "talos_machine_configuration" "gpu_worker" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = var.cluster_endpoint
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.machine_secrets.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  config_patches = concat(
    var.worker_config_patches,
    [
      yamlencode({
        machine = {
          kernel = {
            modules = [
              { name = "nvidia" },
              { name = "nvidia_uvm" },
              { name = "nvidia_drm" },
              { name = "nvidia_modeset" }
            ]
          }
          sysctls = {
            "net.core.bpf_jit_harden" = 1
          }
        }
      })
    ]
  )
  docs     = false
  examples = false
}

resource "talos_machine_configuration_apply" "controlplane" {
  for_each = { for n in var.controlplane_nodes : n.name => n }

  client_configuration        = coalesce(var.client_configuration_override, talos_machine_secrets.machine_secrets.client_configuration)
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = each.value.ip_address
  endpoint                    = each.value.ip_address

  config_patches = [
    yamlencode([
      {
        op    = "replace"
        path  = "/machine/install/disk"
        value = var.install_disk
      }
    ]),
    yamlencode([
      {
        op    = "replace"
        path  = "/machine/network/hostname"
        value = each.value.name
      }
    ]),
    yamlencode([
      {
        op   = "add"
        path = "/machine/network/interfaces"
        value = [
          {
            interface = "enX0"
            dhcp      = true
            vip = {
              ip = var.cluster_vip
            }
          },
          {
            interface = "enX1"
            addresses = ["100.120.0.1${index(sort([for x in var.controlplane_nodes : x.name]), each.value.name)}/24"]
          }
        ]
      }
    ]),
    yamlencode([
      {
        op   = "add"
        path = "/machine/certSANs"
        value = [
          var.cluster_vip,
          each.value.ip_address
        ]
      }
    ])
  ]
}

resource "talos_machine_configuration_apply" "worker" {
  for_each = { for n in var.worker_nodes : n.name => n }

  client_configuration        = coalesce(var.client_configuration_override, talos_machine_secrets.machine_secrets.client_configuration)
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.value.ip_address
  endpoint                    = each.value.ip_address

  config_patches = [
    yamlencode([
      {
        op    = "replace"
        path  = "/machine/install/disk"
        value = var.install_disk
      }
    ]),
    yamlencode([
      {
        op    = "replace"
        path  = "/machine/network/hostname"
        value = each.value.name
      }
    ]),
    yamlencode([
      {
        op   = "add"
        path = "/machine/network/interfaces"
        value = [
          {
            interface = "enX0"
            dhcp      = true
          },
          {
            interface = "enX1"
            addresses = ["100.120.0.2${index(sort([for x in var.worker_nodes : x.name]), each.value.name)}/24"]
          }
        ]
      }
    ])
  ]
}

resource "talos_machine_configuration_apply" "gpu_worker" {
  for_each = { for n in var.gpu_worker_nodes : n.name => n }

  client_configuration        = coalesce(var.client_configuration_override, talos_machine_secrets.machine_secrets.client_configuration)
  machine_configuration_input = data.talos_machine_configuration.gpu_worker.machine_configuration
  node                        = each.value.ip_address
  endpoint                    = each.value.ip_address

  config_patches = [
    yamlencode([
      {
        op    = "replace"
        path  = "/machine/install/disk"
        value = var.install_disk
      }
    ]),
    yamlencode([
      {
        op    = "replace"
        path  = "/machine/network/hostname"
        value = each.value.name
      }
    ]),
    yamlencode([
      {
        op   = "add"
        path = "/machine/network/interfaces"
        value = [
          {
            interface = "enX0"
            dhcp      = true
          },
          {
            interface = "enX1"
            addresses = ["100.120.0.3${index(sort([for x in var.gpu_worker_nodes : x.name]), each.value.name)}/24"]
          }
        ]
      }
    ])
  ]
}

resource "talos_machine_bootstrap" "bootstrap" {
  client_configuration = coalesce(var.client_configuration_override, talos_machine_secrets.machine_secrets.client_configuration)
  node                 = sort([for n in var.controlplane_nodes : n.ip_address])[0]
  endpoint             = sort([for n in var.controlplane_nodes : n.ip_address])[0]

  depends_on = [
    talos_machine_configuration_apply.controlplane
  ]
}

data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster_name
  client_configuration = coalesce(var.client_configuration_override, talos_machine_secrets.machine_secrets.client_configuration)
  endpoints            = [for node in var.controlplane_nodes : node.ip_address]
}

resource "talos_cluster_kubeconfig" "kubeconfig" {
  client_configuration = coalesce(var.client_configuration_override, talos_machine_secrets.machine_secrets.client_configuration)
  node                 = sort([for n in var.controlplane_nodes : n.ip_address])[0]
  endpoint             = sort([for n in var.controlplane_nodes : n.ip_address])[0]

  depends_on = [
    talos_machine_bootstrap.bootstrap
  ]
}

# Apply System Helm Charts

# Apply Application Helm Charts