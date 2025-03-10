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
  description = "Enable ingress for the DS Connector"
  default = {
    apisix  = true
    # False by default for the test environment only!
    ccs     = false
    til     = false
    did     = false
    vcv     = false
    pap     = false
    scorpio = false
    tmf_api = false
    rainbow = false
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
    cm                 = true
    tpp                = true
    rainbow            = true
  }
}

variable "services_names" {
  type        = map(string)
  description = "Services names for the DS Connector"
  default = {
    connector      = "fiware-data-space-connector"
    mysql          = "mysql-db"
    ccs            = "credentials-config-service"
    til            = "trusted-issuers-list"
    did            = "did-helper" # default name, not editable
    vcv            = "vc-verifier"
    postgresql     = "postgresql-db"
    pap            = "pap-odrl"
    apisix_service = "apisix-proxy"
    apisix_api     = "apisix-api"
    postgis        = "postgis-db"
    scorpio        = "scorpio-broker"
    tmf_api        = "tm-forum-api"
    cm             = "contract-management"
    rainbow        = "rainbow"
    tpp_data       = "tpp-rainbow-data"
    tpp_service    = "tpp-rainbow-service"
  }
}

################################################################################
# Services Configuration                                                       #
################################################################################
variable "dataspace_config" {
  type = object({
    port = number
  })
  description = "Data Space Configuration"
  default = {
    port = 3002
  }
}

variable "mysql" {
  type = object({
    port          = number
    secret        = string
    db_name_til   = string
    db_name_ccs   = string
    username_root = string
    secret_key    = string
  })
  description = "MySQL configuration"
  default = {
    port          = 3306
    secret        = "mysql-database-secret"
    db_name_til   = "tildb"
    db_name_ccs   = "ccsdb"
    username_root = "root"
    secret_key    = "mysql-root-password"
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

variable "vcverifier" {
  type = object({
    port = number
  })
  description = "VCVerifier configuration"
  default = {
    port = 3000
  }
}

variable "postgresql" {
  type = object({
    port      = number
    user_name = string
    db_name   = string
    secret    = string
  })
  description = "PostgreSQL configuration"
  default = {
    port      = 5432
    user_name = "postgres"
    db_name   = "pap"
    secret    = "postgresql-database-secret"
  }
}

variable "postgis" {
  type = object({
    port      = number
    user_name = string
    secret    = string
  })
  description = "Postgis configuration"
  default = {
    port      = 5432
    user_name = "postgres"
    secret    = "postgis-database-secret"
  }
}

variable "odrl_pap" {
  type = object({
    port = number
  })
  description = "ODRL-PAP configuration"
  default = {
    port = 8080
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

variable "trusted_issuers_list" {
  type = object({
    port = number
  })
  description = "Trusted Issuers List configuration"
  default = {
    port = 8080
  }
}

variable "scorpio" {
  type = object({
    port = number
  })
  description = "Scorpio configuration"
  default = {
    port = 9090
  }
}

variable "tm_forum_api" {
  type = object({
    port = number
  })
  description = "TM Forum API configuration"
  default = {
    port = 8080
  }
}

variable "contract_management" {
  type = object({
    port = number
  })
  description = "Contract Management configuration"
  default = {
    port = 8080
  }
}

variable "apisix" {
  type = object({
    resource_preset = string
  })
  description = "Apisix configuration"
  default = {
    # Issue solved: https://github.com/FIWARE/data-space-connector/issues/18
    resource_preset = "small"
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
