variable "docker_version" {
  description = "The version of the docker image rancher/k3s"
  type        = string
  default     = "v1.30.2-rc1-k3s2"
}

variable "cluster_name" {
  description = "value of the cluster name"
  type        = string
  default     = "k3s-cluster"
}

variable "k3s_kubeconfig" {
  type = object({
    output_path = string
    output_file = string
    mode        = string
  })
  description = "K3s kubeconfig configuration"
  default = {
    output_path = "/output"
    output_file = "kubeconfig.yaml"
    mode   = "666"
  }
}

variable "add_ports" {
  type = list(
    object(
      {
        internal = number
        external = number
      }
    )
  )
  description = "Extra ports to be added"
  default = [
    {
      internal = 80
      external = 80
    },
    {
      internal = 443
      external = 443
    },
    {
      internal = 6443
      external = 6443
    }
  ]
}
