output "namespace" {
  description = "Namespace de Kubernetes donde está desplegado Traefik"
  value       = kubernetes_namespace.traefik.metadata[0].name
}

output "chart_version" {
  description = "Versión del Helm chart de Traefik instalada"
  value       = helm_release.traefik.version
}

