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

variable "tir_hostname" {
  description = "Hostname of the TIR API (issuer lookup). With the \"tailscale\" class it is the device name in the Tailnet"
  type        = string
  default     = "tir"
}

variable "til_hostname" {
  description = "Hostname of the TIL API (issuer registration). With the \"tailscale\" class it is the device name in the Tailnet"
  type        = string
  default     = "til"
}

variable "postgres_operator_enabled" {
  description = "Installs the PostgreSQL Operator required by the chart"
  type        = bool
  default     = true
}

variable "managed_postgres_enabled" {
  description = "Creates the managed PostgreSQL instance for the TIR"
  type        = bool
  default     = true
}

variable "extra_values" {
  description = "Additional YAML documents that override chart values"
  type        = list(string)
  default     = []
}
