output "tir_service" {
  description = "Service interno del Trusted Issuers List, para llamadas desde otros pods"
  value       = module.trust_anchor.tir_service
}

output "trust_anchor_tir_url" {
  description = "API TIR (consulta de issuers) en la Tailnet"
  value       = "https://${module.trust_anchor.tir_hostname}.${var.tailnet_domain}/v4/issuers"
}

output "trust_anchor_til_url" {
  description = "API TIL (registro de issuers) en la Tailnet"
  value       = "https://${module.trust_anchor.til_hostname}.${var.tailnet_domain}/issuer"
}
