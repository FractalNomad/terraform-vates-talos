output "kubeconfig" {
  description = "Kubeconfig for accessing the Talos cluster"
  value       = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive   = true
}

output "talosconfig" {
  description = "Talosconfig for managing the Talos cluster"
  value       = data.talos_client_configuration.talosconfig.talos_config
  sensitive   = true
}
