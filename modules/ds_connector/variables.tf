variable "kubernetes_local_path" {
  type        = string
  description = "The path to the kubeconfig file"
  default     = "~/.kube/config"
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
# Cluster Configuration                                                        #
################################################################################

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

variable "trust_anchor_domain" {
  type        = string
  description = "Trust Anchor domain (Trusted Participants Registry)"
  default     = "trust-anchor.local"
}

################################################################################
# Services Configuration                                                       #
################################################################################

variable "flags_deployment" {
  type = object({
    mongodb             = bool
    mysql               = bool
    postgresql          = bool
    walt_id             = bool
    tm_forum_api        = bool
    orion_ld            = bool
    ccs                 = bool
    til                 = bool
    verifier            = bool
    contract_management = bool
    activation          = bool
    keycloak            = bool
    keyrock             = bool
    pdp                 = bool
    kong                = bool
  })
  description = "Whether to deploy resources."
  default = {
    mongodb             = true
    mysql               = true
    postgresql          = true
    walt_id             = true
    tm_forum_api        = true
    orion_ld            = true
    ccs                 = true
    til                 = true
    verifier            = true
    contract_management = true
    activation          = true
    keycloak            = true
    keyrock             = true
    pdp                 = true
    kong                = true
  }
}

variable "services_names" {
  type = object({
    connector           = string
    mongo               = string
    mysql               = string
    postgresql          = string
    walt_id             = string
    tm_forum_api        = string
    orion_ld            = string
    ccs                 = string
    til                 = string
    tir                 = string
    verifier            = string
    contract_management = string
    activation          = string
    keycloak            = string
    keyrock             = string
    pdp                 = string
    kong                = string
  })
  description = "Service names (pods)"
  default = {
    connector           = "fiware-data-space-connector"
    mongo               = "mongodb"
    mysql               = "mysql"
    postgresql          = "postgresql"
    walt_id             = "waltid"
    tm_forum_api        = "tm-forum-api"
    orion_ld            = "orionld"
    ccs                 = "cred-conf-service"
    til                 = "trusted-issuers-list"
    tir                 = "trusted-issuers-registry"
    verifier            = "verifier"
    contract_management = "contract-management"
    activation          = "activation-service"
    keycloak            = "keycloak"
    keyrock             = "keyrock"
    pdp                 = "pdp"
    kong                = "kong"
  }
}

variable "did_option" {
  type        = string
  description = "DID option for the services"
  default     = "web"
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
    version    = "2.0.4"
    chart_name = "data-space-connector"
    repository = "https://fiware-ops.github.io/data-space-connector/"
  }
}

variable "mongodb" {
  type = object({
    auth_enabled  = bool
    root_password = string
  })
  description = "MongoDB service configuration"
  default = {
    auth_enabled  = true
    root_password = "root"
  }
}

variable "mysql" {
  type = object({
    root_user_name = string
    root_password  = string
  })
  description = "MySQL service configuration"
  default = {
    root_user_name = "root"
    root_password  = "root"
  }
}

variable "postgresql" {
  type = object({
    root_user_name = string
    root_password  = string
    user_name      = string
    user_password  = string
    db_name        = string
  })
  description = "PostgreSQL service configuration"
  default = {
    root_user_name = "postgres"
    root_password  = "root"
    user_name      = "keycloak"
    user_password  = "keycloak_password"
    db_name        = "keycloak_ips"
  }
}

variable "walt_id" {
  type = object({
    enable_ingress = bool
  })
  description = "Walt-ID service configuration"
  default = {
    enable_ingress = true
  }
}

variable "credentials_config_service" {
  type = object({
    db_name = string
  })
  description = "Credentials Config Service configuration"
  default = {
    db_name = "ccs"
  }
}

variable "trusted_issuers_list" {
  type = object({
    db_name = string
  })
  description = "Trusted Issuers List service configuration"
  default = {
    db_name = "til"
  }
}

variable "verifier" {
  type = object({
    enable_ingress = bool
  })
  description = "Verifier service configuration"
  default = {
    enable_ingress = true
  }
}

variable "activation" {
  type = object({
    enable_ingress = bool
    client_id      = string
  })
  description = "Activaion service configuration"
  default = {
    enable_ingress = true
    client_id      = "ips-activation-service"
  }
}

variable "keycloak" {
  type = object({
    enable_ingress = bool
    admin_user     = string
    admin_password = string
    db_name        = string
    configmap = object({
      did_config = string
      profile    = string
    })
  })
  description = "Keycloak service configuration"
  default = {
    enable_ingress = true
    admin_user     = "admin"
    admin_password = "admin_password"
    db_name        = "keycloak_ips"
    configmap = {
      did_config = "my-keycloak-did-config"
      profile    = "my-keycloak-profile"
    }
  }
}

variable "keyrock" {
  type = object({
    admin_user     = string
    admin_password = string
    admin_email    = string
    db_name        = string
    enable_ingress = bool
  })
  description = "Keyrock service configuration"
  default = {
    admin_user     = "admin"
    admin_password = "admin_password"
    admin_email    = "admin@keyrock-connector.org"
    db_name        = "ar_idm_ips"
    enable_ingress = true
  }
}

variable "kong" {
  type = object({
    enable_ingress = bool
  })
  description = "Kong service configuration"
  default = {
    enable_ingress = true
  }
}
