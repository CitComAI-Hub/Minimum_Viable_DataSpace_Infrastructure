variable "cluster_name" {
  description = "Name of the kind cluster"
  type        = string
  default     = "multi-nodo"
}

variable "node_image" {
  description = "kind node image (sets the Kubernetes version). Leave null to use the kind default."
  type        = string
  default     = null
}

variable "worker_count" {
  description = "Number of worker nodes to create, besides the control-plane"
  type        = number
  default     = 3
}

variable "kubeconfig_path" {
  description = "Path where the kubeconfig of this cluster is written"
  type        = string
  default     = "~/.kube/kind-multi-nodo-config"
}

variable "zones" {
  description = "Simulated zones the workers are spread across (round-robin), via the topology.kubernetes.io/zone label"
  type        = list(string)
  default     = ["zone-a", "zone-b", "zone-c"]
}

variable "add_extra_ports" {
  description = "Control-plane ports mapped to the host, to expose an Ingress Controller or other services"
  type = list(
    object({
      container_port = number
      host_port      = number
      protocol       = optional(string, "TCP")
    })
  )
  default = [
    { container_port = 80, host_port = 80, protocol = "TCP" },
    { container_port = 443, host_port = 443, protocol = "TCP" },
  ]
}
