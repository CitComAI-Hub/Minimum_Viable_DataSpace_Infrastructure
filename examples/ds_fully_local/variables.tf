variable "flags_deployment" {
  type = object({
    ca_configuration = bool
  })
  description = "Whether to deploy resources."
  default = {
    ca_configuration = true # check the value of flags_deployment.cert_trust_manager in conf/kind_cluster.tfvars
  }
}

variable "host" {
  type = string
}

variable "client_certificate" {
  type = string
}

variable "client_key" {
  type = string
}

variable "cluster_ca_certificate" {
  type = string
}
