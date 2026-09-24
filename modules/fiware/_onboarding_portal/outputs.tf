output "namespace" {
  description = "Namespace donde se ha desplegado el portal"
  value       = helm_release.onboarding_portal.namespace
}

output "service_name" {
  description = "Nombre del Service interno del portal"
  value       = var.name
}

output "keycloak_base_url" {
  description = "URL interna base de Keycloak"
  value       = "http://keycloak.${var.namespace}.svc.cluster.local:8080"
}

output "tailscale_hostname" {
  description = "Hostname configurado para el Ingress de Tailscale"
  value       = var.tailscale_enabled ? var.tailscale_hostname : null
}
