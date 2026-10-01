variable "namespace" {
  description = "Namespace of Keycloak and the onboarding portal. It must already exist"
  type        = string
}

variable "tailnet_domain" {
  description = "MagicDNS domain of the Tailnet (e.g. tail1234.ts.net): the public URLs are https://<hostname>.<tailnet_domain>"
  type        = string
}

variable "keycloak_hostname" {
  description = "Tailnet hostname of the Keycloak of the onboarding (OIDC issuer of the portal). Other Keycloaks of the data space get their own hostnames"
  type        = string
  default     = "onboarding-admin"
}

variable "onboarding_hostname" {
  description = "Tailnet hostname of the onboarding portal"
  type        = string
  default     = "onboarding"
}

variable "ingress_class_name" {
  description = "IngressClass of the Ingresses (\"tailscale\" exposes them over HTTPS in the Tailnet)"
  type        = string
  default     = "tailscale"
}

variable "ingress_annotations" {
  description = "Annotations of the Ingresses (e.g. the ingress_annotations output of modules/tailscale)"
  type        = map(string)
  default     = {}
}

variable "egress_proxy_group" {
  description = "Egress ProxyGroup that lets the portal reach Keycloak by its public URL (output egress_proxy_group_name of modules/tailscale)"
  type        = string
  default     = "egress"
}

variable "did_creation_enabled" {
  description = "Applicants register without a DID: the portal generates did:web:<did_hostname>.<tailnet>:<realm> for the realm it provisions, and a did-helper resolves it"
  type        = bool
  default     = true
}

variable "did_hostname" {
  description = "Tailnet hostname of the did-helper, part of every generated DID (did:web:<did_hostname>.<tailnet>:<realm>). Changing it invalidates the DIDs already issued"
  type        = string
  default     = "onboarding-did"
}


variable "realm" {
  description = "Keycloak realm of the onboarding, imported from resources/keycloak-realm-onboarding.json"
  type        = string
  default     = "onboarding"
}

variable "keycloak_admin_username" {
  description = "Keycloak administrator (master realm), also used by the portal to manage users"
  type        = string
  default     = "keycloak-admin"
}

variable "portal_admin_username" {
  description = "Administrator of the onboarding portal, a user of the onboarding realm. Every user of that realm can manage registrations, so it must only hold administrators"
  type        = string
  default     = "admin"
}

variable "portal_admin_image" {
  description = "Image with sh, curl and jq for the Job that creates the portal administrator"
  type        = string
  default     = "alpine/k8s:1.31.0"
}

variable "keycloak_database" {
  description = "PostgreSQL database of Keycloak (e.g. the outputs of modules/postgres/database)"
  type = object({
    host         = string
    port         = optional(number, 5432)
    name         = string
    secret_name  = string
    username_key = optional(string, "username")
    password_key = optional(string, "password")
  })
}

variable "onboarding_database" {
  description = "PostgreSQL database of the onboarding portal (e.g. the outputs of modules/postgres/database)"
  type = object({
    host         = string
    port         = optional(number, 5432)
    name         = string
    secret_name  = string
    username_key = optional(string, "username")
    password_key = optional(string, "password")
  })
}

variable "tir_url" {
  description = "In-cluster URL of the Trusted Issuers Registry where onboarded participants are registered"
  type        = string
}

variable "agreement_document_path" {
  description = "Local PDF that applicants must sign, served at https://<onboarding_hostname>.<tailnet>/documents/agreement.pdf (null = no document)"
  type        = string
  default     = null
}

variable "app" {
  description = "Branding and links of the portal"
  type = object({
    browser_title       = optional(string, "CitCom.ai - Onboarding Data Space")
    enable_theme_toggle = optional(bool, false)
    project_website_url = optional(string, "https://citcomtef.eu/")
    marketplace_url     = optional(string, "")
  })
  default = {}
}

variable "persistence_size" {
  description = "Size of the volume for the files uploaded by applicants"
  type        = string
  default     = "1Gi"
}

variable "storage_class" {
  description = "StorageClass of the upload volume (null = cluster default)"
  type        = string
  default     = null
}

variable "dsc_chart" {
  description = "FIWARE Data Space Connector chart, used only for its Keycloak and did-helper"
  type = object({
    repository = string
    name       = string
    version    = string
  })
  default = {
    repository = "https://fiware.github.io/data-space-connector/"
    name       = "data-space-connector"
    version    = "10.10.1"
  }
}

variable "onboarding_chart" {
  description = "Onboarding portal Helm chart"
  type = object({
    repository = string
    name       = string
    version    = string
  })
  default = {
    repository = "oci://ghcr.io/citcomai-hub/helm"
    name       = "onboarding-citcom"
    version    = "1.1.0"
  }
}

variable "documents_image" {
  description = "Web server image that serves the agreement document"
  type        = string
  default     = "nginxinc/nginx-unprivileged:1.27-alpine"
}

variable "vault_namespace" {
  description = "Namespace where Vault is deployed (output namespace of modules/vault)"
  type        = string
  default     = "vault"
}

variable "vault_address" {
  description = "In-cluster address of Vault (output internal_address of modules/vault)"
  type        = string
  default     = "http://vault.vault.svc.cluster.local:8200"
}
