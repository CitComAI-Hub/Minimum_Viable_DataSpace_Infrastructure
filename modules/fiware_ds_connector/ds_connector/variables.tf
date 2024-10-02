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
    connector      = string
    mysql          = string
    ccs            = string
    til            = string
    did            = string
    vcv            = string
    postgresql     = string
    pap            = string
    postgis        = string
    scorpio        = string
    apisix_service = string
    apisix_api     = string
  })
  description = "Services names for the DS Connector"
  default = {
    connector      = "fiware-data-space-connector"
    mysql          = "mysql"
    ccs            = "credentials-config-service"
    til            = "trusted-issuers-list"
    did            = "did-helper" # default name, not editable
    vcv            = "vc-verifier"
    postgresql     = "postgresql"
    pap            = "pap-odrl"
    postgis        = "postgis-db"
    scorpio        = "scorpio-broker"
    apisix_service = "apisix-proxy"
    apisix_api     = "apisix-api"
  }
}
