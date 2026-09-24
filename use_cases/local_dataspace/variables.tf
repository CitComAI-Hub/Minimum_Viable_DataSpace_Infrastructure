variable "kubeconfig_path" {
  description = "Ruta al kubeconfig generado por kind_cluster"
  type        = string
  default     = "../kind_cluster/cluster-config.yaml"
}

variable "namespace" {
  description = "Namespace del Trust Anchor"
  type        = string
  default     = "trust-anchor"
}

variable "tailscale_hostname" {
  description = "Hostname del TIR en la Tailnet"
  type        = string
  default     = "tir"
}
