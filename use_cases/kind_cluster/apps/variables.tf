variable "kubeconfig_path" {
  description = "Ruta al kubeconfig generado por la capa de cluster (kind_cluster/cluster-config.yaml)"
  type        = string
  default     = "../cluster-config.yaml"
}
