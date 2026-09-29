output "release_name" {
  description = "Name of the deployed Helm release"
  value       = helm_release.trust_anchor.name
}

output "namespace" {
  description = "Trust Anchor namespace"
  value       = helm_release.trust_anchor.namespace
}

output "tir_service" {
  description = "In-cluster Service of the Trusted Issuers List"
  value       = "tir.${var.namespace}.svc.cluster.local:8080"
}

output "tir_hostname" {
  description = "Ingress hostname of the TIR API (null when there is no Ingress)"
  value       = var.ingress_enabled ? var.tir_hostname : null
}

output "til_hostname" {
  description = "Ingress hostname of the TIL API (null when there is no Ingress)"
  value       = var.ingress_enabled ? var.til_hostname : null
}
