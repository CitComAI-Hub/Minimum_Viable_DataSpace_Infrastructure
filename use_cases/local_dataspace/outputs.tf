output "tir_service" {
  description = "In-cluster Service of the Trusted Issuers List, for calls from other pods"
  value       = module.trust_anchor.tir_service
}

output "trust_anchor_tir_url" {
  description = "TIR API (issuer lookup) in the Tailnet"
  value       = "https://${module.trust_anchor.tir_hostname}.${local.tailnet_domain}/v4/issuers"
}

output "trust_anchor_til_url" {
  description = "TIL API (issuer registration) in the Tailnet"
  value       = "https://${module.trust_anchor.til_hostname}.${local.tailnet_domain}/issuer"
}

output "onboarding_url" {
  description = "Onboarding portal in the Tailnet"
  value       = module.onboarding.onboarding_url
}

output "keycloak_admin_console_url" {
  description = "Administration console of the Keycloak of the onboarding"
  value       = module.onboarding.keycloak_admin_console_url
}

output "keycloak_admin_password_command" {
  description = "Command that prints the password of the Keycloak administrator"
  value       = "kubectl --kubeconfig '${abspath(pathexpand(var.kubeconfig_path))}' -n ${var.onboarding_namespace} get secret ${module.onboarding.keycloak_admin_secret} -o jsonpath='{.data.password}' | base64 -d"
}

output "portal_admin_username" {
  description = "Administrator of the onboarding portal (password in Vault: onboarding/portal-admin)"
  value       = module.onboarding.portal_admin_username
}

output "portal_admin_password_command" {
  description = "Command that prints the password of the portal administrator"
  value       = "kubectl --kubeconfig '${abspath(pathexpand(var.kubeconfig_path))}' -n ${var.onboarding_namespace} get secret ${module.onboarding.portal_admin_secret} -o jsonpath='{.data.password}' | base64 -d"
}

output "agreement_document_url" {
  description = "Agreement document that applicants must sign"
  value       = module.onboarding.agreement_document_url
}
