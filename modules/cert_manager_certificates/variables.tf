variable "namespace" {
  type        = string
  description = "The namespace to install cert-manager"
  default     = "cert-manager"
}

variable "data_ca_path" {
  type        = string
  description = "The path to the ca data"
  default     = "data/ssl/ca/"
}

variable "clusterissuer_name" {
  type        = string
  description = "The name of the clusterissuer"
  default     = "ca-certificates"
}

variable "secret_ca_container" {
  type        = string
  description = "The name of the secret container"
  default     = "ca-cert-manager"
}

#! Incomatible when is using as a module
# variable "host" {
#   type = string
# }
# variable "client_certificate" {
#   type = string
# }
# variable "client_key" {
#   type = string
# }
# variable "cluster_ca_certificate" {
#   type = string
# }
