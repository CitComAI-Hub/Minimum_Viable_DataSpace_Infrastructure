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

################################################################################
# Services Configuration                                                       #
################################################################################

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
    enable_service = bool
    auth_enabled   = bool
    root_password  = string
  })
  description = "MongoDB service configuration"
  default = {
    enable_service = true
    auth_enabled   = true
    root_password  = "root"
  }
}

variable "mysql" {
  type = object({
    enable_service = bool
    root_password  = string
  })
  description = "MySQL service configuration"
  default = {
    enable_service = true
    root_password  = "root"
  }

}

variable "postgresql" {
  type = object({
    enable_service = bool
    root_password  = string
    user_name      = string
    user_password  = string
    db_name        = string
  })
  description = "PostgreSQL service configuration"
  default = {
    enable_service = true
    root_password  = "root"
    user_name      = "keycloak"
    user_password  = "keycloak_password"
    db_name        = "keycloak_ips"
  }
}

variable "walt_id" {
  type = object({
    enable_service = bool
    enable_ingress = bool
  })
  description = "Walt-ID service configuration"
  default = {
    enable_service = false
    enable_ingress = true
  }
}

variable "tm_forum_api" {
  type = object({
    enable_service = bool
  })
  description = "TM Forum API service configuration"
  default = {
    enable_service = true
  }
}

variable "orion_ld" {
  type = object({
    enable_service = bool
  })
  description = "Orion-LD service configuration"
  default = {
    enable_service = true
  }

}

variable "credentials_config_service" {
  type = object({
    enable_service = bool
    db_name        = string
  })
  description = "Credentials Config Service configuration"
  default = {
    enable_service = true
    db_name        = "ccs"
  }
}

variable "trusted_issuers_list" {
  type = object({
    enable_service = bool
    db_name        = string
  })
  description = "Trusted Issuers List service configuration"
  default = {
    enable_service = true
    db_name        = "til"
  }
}

variable "verifier" {
  type = object({
    enable_service = bool
    enable_ingress = bool
  })
  description = "Verifier service configuration"
  default = {
    enable_service = true
    enable_ingress = true
  }
}

variable "contract_management" {
  type = object({
    enable_service = bool
  })
  description = "Contract Management service configuration"
  default = {
    enable_service = true
  }
}

variable "activation" {
  type = object({
    enable_service = bool
    enable_ingress = bool
    client_id      = string
  })
  description = "Activaion service configuration"
  default = {
    enable_service = true
    enable_ingress = true
    client_id      = "ips-activation-service"
  }
}

variable "keycloak" {
  type = object({
    enable_service = bool
    enable_ingress = bool
    admin_user     = string
    admin_password = string
    db_name        = string
  })
  description = "Keycloak service configuration"
  default = {
    enable_service = false
    enable_ingress = true
    admin_user     = "admin"
    admin_password = "admin_password"
    db_name        = "keycloak_ips"
  }
}

variable "keyrock" {
  type = object({
    enable_service = bool
    admin_user     = string
    admin_password = string
    admin_email    = string
    db_name        = string
    enable_ingress = bool
  })
  description = "Keyrock service configuration"
  default = {
    enable_service = false
    admin_user     = "admin"
    admin_password = "admin_password"
    admin_email    = "admin@keyrock-connector.org"
    db_name        = "ar_idm_ips"
    enable_ingress = true
  }
}

variable "pdp" {
  type = object({
    enable_service = bool
  })
  description = "PDP service configuration"
  default = {
    enable_service = true
  }
}
