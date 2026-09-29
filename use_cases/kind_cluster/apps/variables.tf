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
