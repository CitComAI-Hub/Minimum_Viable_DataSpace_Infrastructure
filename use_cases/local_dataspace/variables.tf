variable "kubeconfig_path" {
  description = "Ruta al kubeconfig generado por kind_cluster"
  type        = string
  default     = "../kind_cluster/cluster-config.yaml"
}

variable "namespace" {
  description = "Namespace compartido por Keycloak y el portal de onboarding"
  type        = string
  default     = "onboarding"
}

variable "trust_anchor_namespace" {
  description = "Namespace del Trust Anchor"
  type        = string
  default     = "trust-anchor"
}

variable "trust_anchor_tailscale_hostname" {
  description = "Hostname del TIR en la Tailnet"
  type        = string
  default     = "tir"
}

variable "onboarding_tailscale_hostname" {
  description = "Hostname del portal de onboarding en la Tailnet"
  type        = string
  default     = "onboarding"
}

variable "keycloak_public_url" {
  description = "URL pública de Keycloak para los redireccionamientos OIDC"
  type        = string
  default     = "https://keycloak.<tu-tailnet>.ts.net"
}

variable "onboarding_public_url" {
  description = "URL pública del portal de onboarding en la Tailnet"
  type        = string
  default     = "https://onboarding.<tu-tailnet>.ts.net"
}

variable "keycloak_realm" {
  description = "Realm de Keycloak importado para el portal"
  type        = string
  default     = "onboarding"
}

variable "document_to_sign_url" {
  description = "URL pública del documento que el solicitante debe firmar"
  type        = string
  default     = ""
}

variable "keycloak_admin_password" {
  description = "Password del administrador de Keycloak"
  type        = string
  sensitive   = true
  default     = "change-me-keycloak-admin"
}

variable "onboarding_client_secret" {
  description = "Secret del cliente OIDC del onboarding"
  type        = string
  sensitive   = true
  default     = "change-me-onboarding-client"
}

variable "keycloak_store_password" {
  description = "Password del almacén usado por Keycloak"
  type        = string
  sensitive   = true
  default     = "change-me-keycloak-store"
}
