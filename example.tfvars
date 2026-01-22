# Example Terraform variables for terraform-vates-talos
# Populate required variables for modules/talos-cluster and modules/talos-nodes

cluster_name = "example-cluster"
cluster_endpoint = "https://192.168.100.100:6443"
cluster_vip = "192.168.100.100"
install_disk = "/dev/xvda"

controlplane_nodes = [
  {
    ip_address = "192.168.100.10"
    name       = "talos-cp-1"
  },
  {
    ip_address = "192.168.100.11"
    name       = "talos-cp-2"
  },
  {
    ip_address = "192.168.100.12"
    name       = "talos-cp-3"
  }
]

worker_nodes = [
  {
    ip_address = "192.168.100.20"
    name       = "talos-worker-1"
  }
]

gpu_worker_nodes = []

talos_version = "v1.11.2"
kubernetes_version = "1.28.2"

allow_scheduling_on_controlplanes = true

controlplane_config_patches = []
worker_config_patches = []

client_configuration_override = null

# VM/node settings (modules/talos-nodes)
vm_count = 4
vm_name_prefix = "talos-"
template_name = "talos-template"
net_kub_name = "net-kub"
net_san_name = "net-san"
sr_name = "local"
cpus = 4
memory_gb = 8
disk_gb = 64

expected_ip_cidr = "192.168.100.0/24"

additional_tags = ["environment:dev", "owner:example"]
node_type = "worker"

enable_gpu = false
gpu_groups = []
gpu_group_name = ""

auto_poweron = true
power_state = "Running"
