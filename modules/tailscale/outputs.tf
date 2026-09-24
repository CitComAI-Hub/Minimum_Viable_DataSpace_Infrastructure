output "namespace" {
  description = "Namespace donde se ha desplegado el Tailscale Operator"
  value       = kubernetes_namespace.tailscale.metadata[0].name
}

output "operator_name" {
  description = "Nombre de la release de Helm del operador"
  value       = helm_release.tailscale_operator.name
}

output "ingress_class_name" {
  description = "Clase de Ingress a usar en los recursos Ingress de Kubernetes para exponerlos vía Tailscale con TLS automático"
  value       = "tailscale"
}

output "chart_version" {
  description = "Versión del Helm chart instalada"
  value       = helm_release.tailscale_operator.version
}
