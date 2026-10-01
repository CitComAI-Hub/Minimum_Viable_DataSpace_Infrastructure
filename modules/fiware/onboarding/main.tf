# Onboarding of the data space: Keycloak (identity provider of the applicants) and
# the onboarding portal, which registers the approved participants in the TIR.
#
# Every URL is the public Tailnet one, for the browser and for the portal alike:
# openid-client requires the discovery URL to be HTTPS and to match the issuer, so
# the portal reaches Keycloak through the Tailscale egress (modules/tailscale/egress).

locals {
  keycloak_fqdn   = "${var.keycloak_hostname}.${var.tailnet_domain}"
  keycloak_url    = "https://${local.keycloak_fqdn}"
  onboarding_fqdn = "${var.onboarding_hostname}.${var.tailnet_domain}"
  onboarding_url  = "https://${local.onboarding_fqdn}"
  did_web_host    = "did:web:${var.did_hostname}.${var.tailnet_domain}"

  keycloak_admin_secret    = "keycloak-admin"
  portal_admin_secret      = "portal-admin"
  onboarding_client_secret = "onboarding-client"
  onboarding_client_id     = "onboarding-client"
  documents_enabled        = var.agreement_document_path != null
  agreement_document_url   = local.documents_enabled ? "${local.onboarding_url}/documents/agreement.pdf" : ""
  keycloak_service_port    = 8080
  onboarding_service_port  = 80
  documents_service_port   = 80
}

# Keycloak administrator, portal administrator and OIDC client secret of the portal,
# generated in Vault
module "credentials" {
  source = "../../vault/consumer"

  name            = "onboarding"
  namespace       = var.namespace
  vault_namespace = var.vault_namespace
  vault_address   = var.vault_address

  secrets = {
    (local.keycloak_admin_secret) = {
      vault_path       = "onboarding/keycloak-admin"
      static           = { username = var.keycloak_admin_username }
      generated_fields = ["password"]
    }
    (local.portal_admin_secret) = {
      vault_path       = "onboarding/portal-admin"
      static           = { username = var.portal_admin_username }
      generated_fields = ["password"]
    }
    (local.onboarding_client_secret) = {
      vault_path       = "onboarding/client"
      static           = { "client-id" = local.onboarding_client_id }
      generated_fields = ["client-secret"]
    }
  }
}

# Lets the portal pod reach https://<keycloak_fqdn> like any Tailnet device
module "keycloak_egress" {
  source = "../../tailscale/egress"

  name        = "keycloak-tailnet"
  namespace   = var.namespace
  fqdn        = local.keycloak_fqdn
  proxy_group = var.egress_proxy_group

  # The egress proxy resolves the name only when the Service is configured: if the
  # Tailscale Service of Keycloak does not exist yet, it never routes the traffic
  depends_on = [kubernetes_ingress_v1.keycloak]
}
