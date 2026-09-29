output "namespace" {
  description = "Namespace where the Tailscale Operator is deployed"
  value       = kubernetes_namespace.tailscale.metadata[0].name
}

output "operator_name" {
  description = "Helm release name of the operator"
  value       = helm_release.tailscale_operator.name
}

output "ingress_class_name" {
  description = "IngressClass for Kubernetes Ingress resources exposed through Tailscale with automatic TLS"
  value       = "tailscale"
}

output "chart_version" {
  description = "Installed Helm chart version"
  value       = helm_release.tailscale_operator.version
}

output "operator_hostname" {
  description = "Device name of the operator in the Tailnet"
  value       = var.operator_hostname
}
