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

variable "enable_ingress_tls" {
  type        = map(bool)
  description = "Enable ingress TLS for the DS Connector (consumer)"
  default = {
    keycloak = false
  }
}

variable "enable_services" {
  type        = map(bool)
  description = "Enable services for the DS Connector"
  default = {
    registration       = false # only for the test environment
    did                = true
    postgresql         = true
    keycloak           = true
    rainbow            = true
    generate_passwords = true # used by issuance service
    # > Provider only (not editable)
    dsconfig = false
    mysql    = false
    ccs      = false
    til      = false
    vcv      = false
    pap      = false
    opa      = false
    apisix   = false
    postgis  = false
    scorpio  = false
    tmf_api  = false
    cm       = false
    tpp      = false
    dss      = false
    elsi     = false
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

variable "secrets_names" {
  type        = map(string)
  description = "Secrets names for the DS Connector"
  default = {
    issuance = "issuance-secret"
  }

}

################################################################################
# Services Configuration                                                       #
################################################################################
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
    port      = number
    user_name = string
    secret    = string
  })
  description = "PostgreSQL configuration"
  default = {
    port      = 5432
    user_name = "postgres"
    secret    = "postgresql-database-secret"
  }
}

variable "postgresql_secrets_noedit" {
  type        = map(string)
  description = "PostgreSQL configuration (not editable)"
  default = {
    key_adminpass = "postgres-admin-password"
    key_userpass  = "postgres-user-password"
  }
}

variable "keycloak" {
  type        = map(string)
  description = "Keycloak service configuration"
  default = {
    user_key    = "keycloak-admin"
    pass_key    = "keycloak-admin"
    postgres_db = "keycloak"
  }
}

variable "rainbow" {
  type = object({
    port        = number
    postgres_db = string
  })
  description = "Rainbow (Data Space Protocol) configuration"
  default = {
    port        = 8080
    postgres_db = "rainbow"
  }
}
