output "tir_service" {
  description = "Service interno del Trusted Issuers List"
  value       = module.trust_anchor.tir_service
}

output "keycloak_base_url" {
  description = "URL interna de Keycloak"
  value       = module.onboarding_portal.keycloak_base_url
}

output "trust_anchor_tailscale_hostname" {
  description = "Hostname del TIR en la Tailnet"
  value       = module.trust_anchor.tailscale_hostname
}

output "onboarding_tailscale_hostname" {
  description = "Hostname del portal de onboarding en la Tailnet"
  value       = module.onboarding_portal.tailscale_hostname
}
