variable "namespace" {
  description = "Kubernetes namespace where the Tailscale Operator is deployed"
  type        = string
  default     = "tailscale"
}

variable "chart_version" {
  description = "tailscale-operator Helm chart version (null = latest)"
  type        = string
  default     = null
}

variable "oauth_client_id" {
  description = "OAuth Client ID generated in the Tailscale Admin Console (Settings > OAuth clients)"
  type        = string
  sensitive   = true
}

variable "oauth_client_secret" {
  description = "OAuth Client Secret generated in the Tailscale Admin Console"
  type        = string
  sensitive   = true
}

variable "default_tags" {
  description = "Tags the operator assigns to itself and to the devices it creates in the Tailnet"
  type        = list(string)
  default     = ["tag:k8s-operator"]
}

variable "operator_hostname" {
  description = "Device name of the operator in the Tailnet. Keep it unique per cluster to avoid clashes with other clusters in the same Tailnet"
  type        = string
  default     = "tailscale-operator"
}
