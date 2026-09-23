output "cluster_name" {
  description = "Nombre del clúster kind creado"
  value       = kind_cluster.default.name
}

output "kubeconfig_path" {
  description = "Ruta local del kubeconfig generado"
  value       = pathexpand(var.kubeconfig_path)
}

output "endpoint" {
  description = "Endpoint del API server de Kubernetes"
  value       = kind_cluster.default.endpoint
}

output "kubectl_context_hint" {
  description = "Comando para usar este clúster con kubectl"
  value       = "export KUBECONFIG=${pathexpand(var.kubeconfig_path)} && kubectl get nodes -o wide"
}
