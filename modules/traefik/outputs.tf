output "namespace" {
  description = "Kubernetes namespace where Traefik is deployed"
  value       = kubernetes_namespace.traefik.metadata[0].name
}

output "chart_version" {
  description = "Installed Traefik Helm chart version"
  value       = helm_release.traefik.version
}

