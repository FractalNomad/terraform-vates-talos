# Variables for VM configuration
variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 3
}

variable "vm_name_prefix" {
  description = "Prefix for VM names"
  type        = string
  default     = "talos-"
}

variable "template_name" {
  description = "Template name to use for VMs"
  type        = string
}

variable "net_kub_name" {
  description = "Kubernetes network name for VMs"
  type        = string
}

variable "net_san_name" {
  description = "SAN network name for VMs"
  type        = string
}

variable "sr_name" {
  description = "Storage Repository name"
  type        = string
}

variable "cpus" {
  description = "Number of CPU cores per VM"
  type        = number
  default     = 4
}

variable "memory_gb" {
  description = "Memory in GB per VM"
  type        = number
  default     = 8
}

variable "disk_gb" {
  description = "Disk size in GB per VM"
  type        = number
  default     = 64
}

variable "expected_ip_cidr" {
  description = "Expected IP CIDR block for VMs"
  type        = string
  default     = ""
}

variable "additional_tags" {
  description = "Additional tags to apply to VMs"
  type        = list(string)
  default     = []
}

variable "node_type" {
  description = "Type of Talos node (controlplane, worker, etc.)"
  type        = string
  default     = "worker"
}

# GPU Configuration
variable "enable_gpu" {
  description = "Enable GPU passthrough for VMs"
  type        = bool
  default     = false
}

variable "gpu_groups" {
  description = "List of GPU group IDs to attach to VMs (one per VM)"
  type        = list(string)
  default     = []
}

variable "gpu_group_name" {
  description = "Name of GPU group to lookup and attach (alternative to gpu_groups)"
  type        = string
  default     = ""
}

variable "auto_poweron" {
  description = "Automatically power on VMs after creation"
  type        = bool
  default     = true
}

variable "power_state" {
  description = "Power state of VMs (Running or Halted)"
  type        = string
  default     = "Running"
  validation {
    condition     = contains(["Running", "Halted"], var.power_state)
    error_message = "Power state must be either 'Running' or 'Halted'."
  }
}