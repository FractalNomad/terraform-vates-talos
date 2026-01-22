terraform-vates-talos

Minimal Terraform modules to provision Talos clusters and VMs on Vates/XenServer environments.

Quick start

1. Copy example.tfvars and edit values:

   cp example.tfvars my.tfvars
   # Edit my.tfvars to match your environment (cluster VIPs, template, networks, SR)

2. Initialize and apply Terraform:

   terraform init
   terraform apply -var-file=my.tfvars

Variables

- Use modules/talos-cluster (controlplane, worker, gpu worker) and modules/talos-nodes for VM resources.
- See example.tfvars for a minimal working set of variables, including controlplane_nodes and worker_nodes.

Scheduling on control planes

- To allow workloads on control plane nodes, set allow_scheduling_on_controlplanes = true in your tfvars. This sets cluster.allowSchedulingOnControlPlanes in generated Talos config.

Notes

- The modules expect existing VM templates, networks and a storage repository in your Vates/XenServer environment.
- GPU support is available via the gpu_worker_nodes and gpu_groups variables.

License

MIT