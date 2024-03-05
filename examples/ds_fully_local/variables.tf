variable "cluster_name" {
  type        = string
  description = "The name of the kind cluster"
  default     = "ds-local-cluster"
}

variable "deploy_portainer" {
  type        = bool
  description = "Whether to deploy Portainer CE"
  default     = false
}