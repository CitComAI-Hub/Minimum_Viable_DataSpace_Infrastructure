variable "cluster_name" {
  type        = string
  description = "The name of the kind cluster"
  default     = "cluster-minimal-ds"
}

variable "kubernetes_local_path" {
  type        = string
  description = "The path to the kubeconfig file"
  default     = "./kind-config_minimalDS.yaml"
}
