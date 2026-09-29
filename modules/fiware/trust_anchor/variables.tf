variable "namespace" {
  description = "Namespace where the Trust Anchor is deployed"
  type        = string
  default     = "trust-anchor"
}
variable "release_name" {
  description = "Helm release name of the Trust Anchor"
  type        = string
  default     = "trust-anchor"
}

variable "trust_anchor" {
  type = object({
    version    = string
    chart_name = string
    repository = string
  })
  description = "Fiware minimal Trust Anchor (DS Operator)"
  default = {
    version    = "1.3.0"
    chart_name = "trust-anchor"
    repository = "https://fiware.github.io/data-space-connector/"
  }
}

variable "ingress_enabled" {
  description = "Exposes the TIR and TIL APIs with one Ingress each"
  type        = bool
  default     = true
}

variable "ingress_class_name" {
  description = "IngressClass of the Ingresses (\"tailscale\" exposes them over HTTPS in the Tailnet)"
  type        = string
  default     = "tailscale"
}

variable "ingress_annotations" {
  description = "Annotations of both Ingresses (e.g. the ingress_annotations output of modules/tailscale)"
  type        = map(string)
  default     = {}
}

variable "tir_hostname" {
  description = "Hostname of the TIR API (issuer lookup). With the \"tailscale\" class it is its Tailnet name (<hostname>.<tailnet>.ts.net)"
  type        = string
  default     = "tir"
}

variable "til_hostname" {
  description = "Hostname of the TIL API (issuer registration). With the \"tailscale\" class it is its Tailnet name (<hostname>.<tailnet>.ts.net)"
  type        = string
  default     = "til"
}

variable "database" {
  description = <<-EOT
    PostgreSQL database of the Trusted Issuers List (e.g. the outputs of modules/postgres/database):
    - secret_name: Secret in the Trust Anchor namespace that holds the password
    - password_key: key of the password in that Secret
  EOT
  type = object({
    host         = string
    port         = optional(number, 5432)
    name         = string
    username     = string
    secret_name  = string
    password_key = optional(string, "password")
  })
  default = {
    host         = "postgresql"
    port         = 5432
    name         = "trust_anchor"
    username     = "trust_anchor"
    secret_name  = "trust-anchor-db-password"
    password_key = "password"
  }
}

variable "extra_values" {
  description = "Additional YAML documents that override chart values"
  type        = list(string)
  default     = []
}
