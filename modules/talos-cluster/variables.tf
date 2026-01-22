# Cluster configuration variables
variable "cluster_name" {
  description = "Name of the Talos cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Cluster VIP endpoint (e.g., https://192.168.1.100:6443)"
  type        = string
}

variable "cluster_vip" {
  description = "Cluster VIP address for Talos (e.g., 10.0.10.30)"
  type        = string
}

variable "install_disk" {
  description = "Target disk for Talos installation"
  type        = string
  default     = "/dev/xvda"
}

# Node configuration
variable "controlplane_nodes" {
  description = "List of control plane nodes with IP addresses"
  type = list(object({
    ip_address = string
    name       = string
  }))
}

variable "worker_nodes" {
  description = "List of worker nodes with IP addresses"
  type = list(object({
    ip_address = string
    name       = string
  }))
  default = []
}

variable "gpu_worker_nodes" {
  description = "List of GPU worker nodes with IP addresses"
  type = list(object({
    ip_address = string
    name       = string
  }))
  default = []
}

# Version configuration
variable "talos_version" {
  description = "Talos version to use"
  type        = string
  default     = "v1.11.2"
}

variable "kubernetes_version" {
  description = "Kubernetes version to use"
  type        = string
  default     = ""
}

# Configuration patches
variable "controlplane_config_patches" {
  description = "List of configuration patches for control plane nodes"
  type        = list(string)
  default     = []
}



variable "worker_config_patches" {
  description = "List of configuration patches for worker nodes"
  type        = list(string)
  default     = []
}

# Optional override for Talos client configuration (talosconfig)
# If provided, this will be used instead of the generated machine secrets client config.
variable "client_configuration_override" {
  description = "Override for Talos client configuration (object with ca, crt, key). Leave null to use generated."
  type = object({
    ca  = string
    crt = string
    key = string
  })
  default  = null
  nullable = true
}

variable "hybrid_controlplane_nodes" {
  description = "List of control plane nodes that should be schedulable (no control-plane taint)"
  type = list(object({
    ip_address = string
    name       = string
  }))
  default = []
}

variable "allow_scheduling_on_controlplanes" {
  description = "Enable scheduling on control plane nodes (sets cluster.allowSchedulingOnControlPlanes=true)"
  type        = bool
  default     = false
}