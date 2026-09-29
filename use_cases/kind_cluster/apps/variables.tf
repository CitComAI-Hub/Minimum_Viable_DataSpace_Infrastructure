variable "kubeconfig_path" {
  description = "Ruta al kubeconfig generado por la capa de cluster (kind_cluster/cluster-config.yaml)"
  type        = string
  default     = "../cluster-config.yaml"
}

variable "cluster_name" {
  description = "Nombre del clúster kind. Se usa para nombrar el operador en la Tailnet (<cluster_name>-ts-operator)"
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
