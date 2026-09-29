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

output "tir_hostname" {
  description = "Hostname del Ingress de la API TIR (null si no hay Ingress)"
  value       = var.ingress_enabled ? var.tir_hostname : null
}

output "til_hostname" {
  description = "Hostname del Ingress de la API TIL (null si no hay Ingress)"
  value       = var.ingress_enabled ? var.til_hostname : null
}
