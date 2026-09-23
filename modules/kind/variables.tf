variable "cluster_name" {
  description = "Nombre del clúster kind"
  type        = string
  default     = "multi-nodo"
}

variable "node_image" {
  description = "Imagen de nodo de kind (controla la versión de Kubernetes). Déjalo en null para usar la versión por defecto de kind."
  type        = string
  default     = null
}

variable "worker_count" {
  description = "Número de nodos worker a crear, aparte del control-plane"
  type        = number
  default     = 3
}

variable "kubeconfig_path" {
  description = "Ruta donde se escribirá el kubeconfig de este clúster"
  type        = string
  default     = "~/.kube/kind-multi-nodo-config"
}

variable "zones" {
  description = "Zonas simuladas entre las que se reparten los workers (round-robin), vía el label topology.kubernetes.io/zone"
  type        = list(string)
  default     = ["zone-a", "zone-b", "zone-c"]
}

variable "add_extra_ports" {
  description = "Puertos del control-plane a mapear al host, para exponer un Ingress Controller u otros servicios"
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
