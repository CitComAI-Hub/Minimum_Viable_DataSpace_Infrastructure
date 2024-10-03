################################################################################
# Kubernetes cluster                                                           #
################################################################################
variable "kubernetes_local_path" {
  type        = string
  description = "The path to the kubeconfig file"
  default     = "~/.kube/config"
}

variable "timeout" {
  type        = number
  description = "Timeout for the helm installation (default 40 minutes)"
  default     = 2400
}

variable "ingress_class" {
  type        = string
  description = "Ingress class for the DS operator deployment (nginx or traefik)"
  default     = "traefik"
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
  type        = map(string)
  description = "Fiware Data Space Connector"
  default = {
    version    = "7.3.1"
    chart_name = "data-space-connector"
    repository = "https://fiware.github.io/data-space-connector/"
  }
}

## Services Configuration ##
variable "enable_services" {
  type        = map(bool)
  description = "Enable services for the DS Connector"
  default = {
    generate_passwords = true
    dsconfig           = true
    mysql              = true
    ccs                = true
    til                = true
    did                = true
    vcv                = true
    postgresql         = true
    pap                = true
    opa                = true
    apisix_service     = true
    postgis            = true
    scorpio            = true
    tmf_api            = true
  }
}

variable "enable_ingress" {
  type        = map(bool)
  description = "Enable ingress for the DS Connector"
  default = {
    til     = true # True only in test environment
    did     = true
    vcv     = true
    pap     = true
    apisix  = true
    scorpio = true # True only in test environment
    tmf_api = true
  }
}

variable "services_names" {
  type        = map(string)
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
    apisix_service = "apisix-proxy"
    apisix_api     = "apisix-api"
    postgis        = "postgis-db"
    scorpio        = "scorpio-broker"
    tmf_api        = "tm-forum-api"
  }
}

variable "mysql" {
  type        = map(string)
  description = "MySQL configuration"
  default = {
    secret      = "mysql-database-secret"
    db_name_til = "tildb"
    db_name_ccs = "ccsdb"
    root_pass   = "root"
    secret_key  = "mysql-root-password"
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
    port         = 3002
    country      = "DE"
    state        = "SAXONY"
    locality     = "Dresden"
    organization = "M&P Operations Inc."
    common_name  = "www.mp-operation.org"
  }
}

variable "postgresql" {
  type        = map(string)
  description = "PostgreSQL configuration"
  default = {
    user_name = "postgres"
    db_name   = "pap"
    secret    = "postgresql-database-secret"
  }
}

variable "postgis" {
  type        = map(string)
  description = "Postgis configuration"
  default = {
    user_name = "postgres"
    secret    = "postgis-database-secret"
  }
}

variable "credentials_config_service" {
  type = object({
    port = number
  })
  description = "Credentials Configuration Service configuration"
  default = {
    port = 8080
  }
}
