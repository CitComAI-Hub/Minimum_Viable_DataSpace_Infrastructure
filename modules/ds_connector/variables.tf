variable "kubernetes_local_path" {
  type        = string
  description = "The path to the kubeconfig file"
  default     = "~/.kube/config"
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
    connector = string
    mongo     = string
    mysql     = string
    orion_ld  = string
    ccs       = string
    til       = string
  })
  description = "Service names (pods)"
  default = {
    connector = "fiware-data-space-connector"
    mongo     = "mongodb"
    mysql     = "mysql"
    orion_ld  = "orionld"
    ccs       = "cred-conf-service"
    til       = "trusted-issuers-list"
  }
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

variable "activation" {
  type = object({
    enable_service = bool
    name_service   = string
    enable_ingress = bool
  })
  description = "Activaion service configuration"
  default = {
    enable_service = false
    name_service   = "activation-service"
    enable_ingress = true
  }
}
