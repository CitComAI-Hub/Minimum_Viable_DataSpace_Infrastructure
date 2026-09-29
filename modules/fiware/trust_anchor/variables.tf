variable "namespace" {
  description = "Namespace donde se desplegará el Trust Anchor"
  type        = string
  default     = "trust-anchor"
}
variable "release_name" {
  description = "Nombre del release Helm del Trust Anchor"
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
  description = "Expone las APIs TIR y TIL mediante un Ingress cada una"
  type        = bool
  default     = true
}

variable "ingress_class_name" {
  description = "IngressClass de los Ingress (\"tailscale\" para exponerlos por HTTPS en la Tailnet)"
  type        = string
  default     = "tailscale"
}

variable "tir_hostname" {
  description = "Hostname de la API TIR (consulta de issuers). Con la clase \"tailscale\" es el nombre del dispositivo en la Tailnet"
  type        = string
  default     = "tir"
}

variable "til_hostname" {
  description = "Hostname de la API TIL (registro de issuers). Con la clase \"tailscale\" es el nombre del dispositivo en la Tailnet"
  type        = string
  default     = "til"
}

variable "postgres_operator_enabled" {
  description = "Instala el PostgreSQL Operator requerido por el chart"
  type        = bool
  default     = true
}

variable "managed_postgres_enabled" {
  description = "Crea la instancia PostgreSQL gestionada para el TIR"
  type        = bool
  default     = true
}

variable "extra_values" {
  description = "Ficheros YAML adicionales para sobrescribir valores del chart"
  type        = list(string)
  default     = []
}
