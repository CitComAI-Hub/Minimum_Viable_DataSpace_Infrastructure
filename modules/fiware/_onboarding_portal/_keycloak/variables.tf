variable "namespace" {
  description = "Namespace de Kubernetes donde se desplegará el portal"
  type        = string
  default     = "onboarding"
}

variable "keycloak_pass" {
  description = "Password for Keycloak admin. If not provided, a random password will be generated."
  type        = string
  default     = null
}
