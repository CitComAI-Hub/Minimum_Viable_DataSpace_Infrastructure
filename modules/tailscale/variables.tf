variable "namespace" {
  description = "Kubernetes namespace where the Tailscale Operator is deployed"
  type        = string
  default     = "tailscale"
}

variable "chart_version" {
  description = "tailscale-operator Helm chart version. The ProxyClass and ProxyGroup manifests are written against its CRDs"
  type        = string
  default     = "1.102.4"
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

variable "operator_tags" {
  description = "Tags of the operator device. The OAuth client must carry them"
  type        = list(string)
  default     = ["tag:k8s-operator"]
}

variable "proxy_tags" {
  description = "Tags of the proxy devices and of the Tailscale Services they publish. The operator tags must own them, and the Tailnet policy must auto-approve the services"
  type        = list(string)
  default     = ["tag:k8s"]
}

variable "operator_hostname" {
  description = "Device name of the operator in the Tailnet. Keep it unique per cluster to avoid clashes with other clusters in the same Tailnet"
  type        = string
  default     = "tailscale-operator"
}

variable "proxy_group_name" {
  description = "Name of the ingress ProxyGroup that serves every Ingress annotated with it"
  type        = string
  default     = "ingress"
}

variable "proxy_group_hostname_prefix" {
  description = "Prefix of the ProxyGroup device names in the Tailnet (<prefix>-0, <prefix>-1...). Keep it unique per cluster"
  type        = string
  default     = "ingress"
}

variable "proxy_group_replicas" {
  description = "Number of ProxyGroup replicas (one Tailnet device each)"
  type        = number
  default     = 1
}

variable "letsencrypt_staging" {
  description = "Issues the Ingress certificates from Let's Encrypt staging: not publicly trusted (browsers block them because ts.net is HSTS preloaded, curl needs -k) but with much higher rate limits than production (5 certificates per hostname per week). Switching back to false re-issues production certificates"
  type        = bool
  default     = false
}
