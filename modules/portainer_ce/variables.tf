variable "img_version" {
  type        = string
  description = "Portainer docker image version"
  default     = "2.19.4"
}

variable "portainer_k8s_file_config" {
  type        = string
  description = "Portainer k8s file config"
  default     = "https://downloads.portainer.io/ce2-19/portainer-agent-k8s-lb.yaml"
}
