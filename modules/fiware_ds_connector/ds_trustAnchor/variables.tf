################################################################################
# Kubernetes cluster                                                           #
################################################################################
variable "kubernetes_local_path" {
  type        = string
  description = "The path to the kubeconfig file"
  default     = "~/.kube/config"
}

variable "namespace" {
  type        = string
  description = "Namespace for the DS operator deployment"
  default     = "ds-trust-anchor"
}

variable "service_domain" {
  type        = string
  description = "Data Space domain"
  default     = "ds-trust-anchor.local"
}

################################################################################
# Certs Configuration Module                                                   #
################################################################################
variable "ca_clusterissuer_name" {
  type        = string
  description = "The name of the clusterissuer"
  default     = "ca-certificates"
}

################################################################################
# Helm Configuration                                                           #
################################################################################
variable "trust_anchor" {
  type = object({
    version    = string
    chart_name = string
    repository = string
  })
  description = "Fiware minimal Trust Anchor (DS Operator)"
  default = {
    version    = "0.2.0"
    chart_name = "trust-anchor"
    repository = "https://fiware.github.io/data-space-connector/"
  }
}

################################################################################
# Services Configuration                                                       #
################################################################################
variable "services_names" {
  type = object({
    trust_anchor = string
    mysql        = string
    til          = string
    tir          = string
  })
  description = "Services names for the DS Operator"
  default = {
    trust_anchor = "fiware-minimal-trust-anchor"
    mysql        = "mysql"
    til          = "trusted-issuers-list"
    tir          = "trusted-issuers-registry"
  }
}
