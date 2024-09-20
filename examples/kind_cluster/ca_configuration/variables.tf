variable "cluster_name" {
  type        = string
  description = "The name of the kind cluster"
  default     = "kind-cluster"
}

variable "kubernetes_local_path" {
  type        = string
  description = "The path to the kubeconfig file"
  default     = "../cluster-config.yaml"
}

variable "ca_clusterissuer_name" {
  type        = string
  description = "The name of the CA module"
  default     = "ca-certificates"
}
