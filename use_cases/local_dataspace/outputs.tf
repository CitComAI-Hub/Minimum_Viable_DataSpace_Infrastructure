output "tir_service" {
  description = "Service interno del Trusted Issuers List"
  value       = module.trust_anchor.tir_service
}

output "tailscale_hostname" {
  description = "Hostname del TIR en la Tailnet"
  value       = module.trust_anchor.tailscale_hostname
}
