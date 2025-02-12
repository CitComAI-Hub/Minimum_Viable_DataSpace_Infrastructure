################################################################################
# Kubernetes cluster                                                           #
################################################################################
variable "kubernetes_local_path" {
  type        = string
  description = "The path to the kubeconfig file"
  default     = "~/.kube/config"
}

variable "operator_namespace" {
  type        = string
  description = "Namespace for the DS operator deployment"
  default     = "ds-operator"
}

variable "provider_namespace" {
  type        = string
  description = "Namespace for the DS provider deployment"
  default     = "ds-provider"
}

variable "namespace" {
  type        = string
  description = "Namespace for the DS operator deployment"
  default     = "ds-consumer"
}

variable "service_domain" {
  type        = string
  description = "Data Space domain"
  default     = "ds-consumer.local"
}

variable "ingress_class" {
  type        = string
  description = "Ingress class for the DS operator deployment (nginx or traefik)"
  default     = "traefik"
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
  type        = map(string)
  description = "Fiware Data Space Connector"
  default = {
    version    = "7.29.0"
    chart_name = "data-space-connector"
    repository = "https://fiware.github.io/data-space-connector/"
  }
}

variable "enable_ingress" {
  type        = map(bool)
  description = "Enable ingress for the DS Connector (consumer)"
  default = {
    did      = true
    keycloak = true
    rainbow  = true
  }
}

variable "enable_services" {
  type        = map(bool)
  description = "Enable services for the DS Connector"
  default = {
    keycloak           = true
    registration       = true
    dsconfig           = false
    generate_passwords = true
    did                = true
    postgresql         = true
    rainbow            = true
  }
}

variable "services_names" {
  type        = map(string)
  description = "Services names for the DS Connector"
  default = {
    connector  = "fiware-data-space-connector"
    keycloak   = "keycloak"
    did        = "did-helper" # default name, not editable
    postgresql = "postgresql"
    rainbow    = "rainbow"
  }
}

################################################################################
# Services Configuration                                                       #
################################################################################
variable "trusted_issuers_list_names" {
  type        = map(string)
  description = "Trusted Issuers List service name in the Operator and Provider namespaces"
  default = {
    operator = "trusted-issuers-list"
    provider = "trusted-issuers-list"
  }
}

variable "keycloak" {
  type        = map(string)
  description = "Keycloak service configuration"
  default = {
    user_key = "keycloak-admin"
    pass_key = "keycloak-admin"
  }
}

variable "did" {
  type = object({
    port         = number
    country      = string
    state        = string
    locality     = string
    organization = string
    common_name  = string
  })
  description = "DID service configuration"
  default = {
    port         = 3001
    country      = "BE"
    state        = "BRUSSELS"
    locality     = "Brussels"
    organization = "Fancy Marketplace Co."
    common_name  = "www.fancy-marketplace.biz"
  }
}

variable "postgresql" {
  type = object({
    port             = number
    user_name        = string
    keycloak_db_name = string
    secret           = string
  })
  description = "PostgreSQL configuration"
  default = {
    port             = 5432
    user_name        = "postgres"
    keycloak_db_name = "keycloak"
    secret           = "postgresql-database-secret"
  }
}

variable "rainbow" {
  type = object({
    port = number
  })
  description = "Rainbow (Data Space Protocol) configuration"
  default = {
    port = 8080
  }
}
