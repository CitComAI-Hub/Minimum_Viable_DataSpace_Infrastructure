output "onboarding_url" {
  description = "Public URL of the onboarding portal"
  value       = local.onboarding_url
  depends_on  = [kubernetes_ingress_v1.onboarding]
}

output "keycloak_url" {
  description = "Public URL of Keycloak (OIDC issuer: <keycloak_url>/realms/<realm>)"
  value       = local.keycloak_url
  depends_on  = [kubernetes_ingress_v1.keycloak]
}

output "keycloak_admin_console_url" {
  description = "Keycloak administration console"
  value       = "${local.keycloak_url}/admin/"
}

output "agreement_document_url" {
  description = "Public URL of the agreement document (empty when there is none)"
  value       = local.agreement_document_url
}

output "portal_admin_username" {
  description = "Administrator of the onboarding portal (user of the onboarding realm)"
  value       = var.portal_admin_username
  depends_on  = [kubernetes_job_v1.portal_admin]
}

output "portal_admin_secret" {
  description = "Secret in the namespace with the portal administrator credentials (keys username and password, Vault path onboarding/portal-admin)"
  value       = local.portal_admin_secret
}

output "keycloak_admin_secret" {
  description = "Secret in the namespace with the Keycloak administrator credentials (keys username and password)"
  value       = local.keycloak_admin_secret
}
