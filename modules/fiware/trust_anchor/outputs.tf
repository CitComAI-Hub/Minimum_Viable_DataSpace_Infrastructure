output "release_name" {
  description = "Nombre del release Helm desplegado"
  value       = helm_release.trust_anchor.name
}

output "namespace" {
  description = "Namespace del Trust Anchor"
  value       = helm_release.trust_anchor.namespace
}

output "tir_service" {
  description = "Service interno del Trusted Issuers List"
  value       = "tir.${var.namespace}.svc.cluster.local:8080"
}

output "tailscale_hostname" {
  description = "Hostname configurado para acceder al TIR desde Tailscale"
  value       = var.tailscale_enabled ? var.tailscale_hostname : null
}
