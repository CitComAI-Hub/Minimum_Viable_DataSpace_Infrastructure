variable "cert_manager_version" {
  type        = string
  description = "The path to the ingress config file"
  default     = "https://github.com/cert-manager/cert-manager/releases/download/v1.14.3/cert-manager.crds.yaml"
}

variable "namespace" {
  type        = string
  description = "The namespace to install cert-manager"
  default     = "cert-manager"
}
