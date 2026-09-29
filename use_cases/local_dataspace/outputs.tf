output "tir_service" {
  description = "In-cluster Service of the Trusted Issuers List, for calls from other pods"
  value       = module.trust_anchor.tir_service
}

output "trust_anchor_tir_url" {
  description = "TIR API (issuer lookup) in the Tailnet"
  value       = "https://${module.trust_anchor.tir_hostname}.${var.tailnet_domain}/v4/issuers"
}

output "trust_anchor_til_url" {
  description = "TIL API (issuer registration) in the Tailnet"
  value       = "https://${module.trust_anchor.til_hostname}.${var.tailnet_domain}/issuer"
}
