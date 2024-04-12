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
  })
  description = "Service names (pods)"
  default = {
    connector = "fiware-data-space-connector"
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
    name_service   = string
    auth_enabled   = bool
    root_password  = string
  })
  description = "MongoDB service configuration"
  default = {
    enable_service = true
    name_service   = "mongodb"
    auth_enabled   = true
    root_password  = "root"
  }
}

variable "mysql" {
  type = object({
    enable_service = bool
    name_service   = string
    root_password  = string
  })
  description = "MySQL service configuration"
  default = {
    enable_service = true
    name_service   = "mysql"
    root_password  = "root"
  }

}

variable "credentials_config_service" {
  type = object({
    enable_service = bool
    name_service   = string
    db_name        = string
  })
  description = "Credentials Config Service configuration"
  default = {
    enable_service = true
    name_service   = "credentials-config-service"
    db_name        = "ccs"
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
