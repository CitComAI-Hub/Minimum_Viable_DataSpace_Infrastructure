variable "namespace" {
  description = "Namespace de Kubernetes donde se desplegará el Tailscale Operator"
  type        = string
  default     = "tailscale"
}

variable "chart_version" {
  description = "Versión del Helm chart de tailscale-operator"
  type        = string
  default     = null
}

variable "oauth_client_id" {
  description = "OAuth Client ID generado en Tailscale Admin Console (Settings > OAuth clients)"
  type        = string
  sensitive   = true
}

variable "oauth_client_secret" {
  description = "OAuth Client Secret generado en Tailscale Admin Console"
  type        = string
  sensitive   = true
}

variable "default_tags" {
  description = "Tags que el operador asignará a los nodos creados en la tailnet"
  type        = list(string)
  default     = ["tag:k8s-operator"]
}
