variable "namespace" {
  description = "Namespace where Vault and its bootstrap are deployed"
  type        = string
  default     = "vault"
}

variable "chart_version" {
  description = "hashicorp/vault chart version"
  type        = string
  default     = "0.34.1"
}

variable "ingress_enabled" {
  description = "Exposes the Vault UI and API through an Ingress"
  type        = bool
  default     = true
}

variable "ingress_class_name" {
  description = "IngressClass of the Vault Ingress (\"tailscale\" exposes it over HTTPS in the Tailnet)"
  type        = string
  default     = "tailscale"
}

variable "ingress_annotations" {
  description = "Annotations of the Vault Ingress (e.g. the ingress_annotations output of modules/tailscale)"
  type        = map(string)
  default     = {}
}

variable "hostname" {
  description = "Hostname of the Vault Ingress. With the \"tailscale\" class it is its Tailnet name (<hostname>.<tailnet>.ts.net)"
  type        = string
  default     = "vault"
}

variable "storage_size" {
  description = "Size of the Vault data PVC"
  type        = string
  default     = "1Gi"
}

variable "storage_class" {
  description = "StorageClass of the Vault data PVC (null = cluster default)"
  type        = string
  default     = null
}

variable "eso_namespace" {
  description = "Namespace where External Secrets Operator is deployed"
  type        = string
  default     = "external-secrets"
}

variable "eso_chart_version" {
  description = "external-secrets chart version"
  type        = string
  default     = "2.11.0"
}

variable "bootstrap_image" {
  description = "Image with sh, curl, jq and kubectl for the bootstrap"
  type        = string
  default     = "alpine/k8s:1.31.0"
}
