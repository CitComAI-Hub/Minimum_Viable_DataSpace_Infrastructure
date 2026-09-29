variable "kubeconfig_path" {
  description = "Path to the kubeconfig written by the cluster layer (kind_cluster/cluster-config.yaml)"
  type        = string
  default     = "../cluster-config.yaml"
}

variable "cluster_name" {
  description = "Name of the kind cluster. Used to name the operator in the Tailnet (<cluster_name>-ts-operator)"
  type        = string
  default     = "kind-cluster"
}

variable "tailscale_oauth_client_id" {
  description = "Tailscale OAuth Client ID"
  type        = string
  sensitive   = true
}

variable "tailscale_oauth_client_secret" {
  description = "Tailscale OAuth Client Secret"
  type        = string
  sensitive   = true
}

variable "tailnet_domain" {
  description = "MagicDNS domain of the Tailnet (e.g. tail1234.ts.net), only used to print full URLs in the outputs"
  type        = string
  default     = "<your-tailnet>.ts.net"
}

variable "vault_hostname" {
  description = "Tailnet hostname of the Vault UI and API"
  type        = string
  default     = "vault"
}

variable "tailscale_letsencrypt_staging" {
  description = "Issues the HTTPS certificates of the Tailnet services from Let's Encrypt staging: no production limit of 5 certificates per hostname per week, but not publicly trusted. Browsers block them without a way to continue (ts.net is HSTS preloaded) and curl needs -k"
  type        = bool
  default     = false
}
