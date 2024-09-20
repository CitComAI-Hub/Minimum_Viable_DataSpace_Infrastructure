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
  default     = "ds-connector"
}

variable "service_domain" {
  type        = string
  description = "Data Space domain"
  default     = "ds-connector.local"
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
variable "connector" {
  type = object({
    version    = string
    chart_name = string
    repository = string
  })
  description = "Fiware Data Space Connector"
  default = {
    version    = "7.3.1"
    chart_name = "data-space-connector"
    repository = "https://fiware.github.io/data-space-connector/"
  }
}

################################################################################
# Services Configuration                                                       #
################################################################################
variable "services_names" {
  type = object({
    connector  = string
    mysql      = string
    postgresql = string
    til        = string
    ccs        = string
  })
  description = "Services names for the DS Connector"
  default = {
    connector  = "fiware-data-space-connector"
    mysql      = "mysql"
    postgresql = "postgresql"
    til        = "trusted-issuers-list"
    ccs        = "credentials-config-service"
  }
}
