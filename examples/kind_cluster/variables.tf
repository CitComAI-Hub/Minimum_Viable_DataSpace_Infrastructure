variable "cluster_name" {
  type        = string
  description = "The name of the kind cluster"
  default     = "ds-local-cluster"
}

variable "add_extra_mounts" {
  type = list(
    object(
      {
        host_path      = string
        container_path = string
      }
    )
  )
  description = "Extra mounts to be added to all nodes"
  default     = []
}
