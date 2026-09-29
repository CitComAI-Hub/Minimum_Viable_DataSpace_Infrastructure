output "cluster_name" {
  description = "Name of the created kind cluster"
  value       = kind_cluster.default.name
}

output "kubeconfig_path" {
  description = "Local path of the generated kubeconfig"
  value       = pathexpand(var.kubeconfig_path)
}

output "endpoint" {
  description = "Kubernetes API server endpoint"
  value       = kind_cluster.default.endpoint
}

output "kubectl_context_hint" {
  description = "Command to use this cluster with kubectl"
  value       = "export KUBECONFIG=${pathexpand(var.kubeconfig_path)} && kubectl get nodes -o wide"
}
