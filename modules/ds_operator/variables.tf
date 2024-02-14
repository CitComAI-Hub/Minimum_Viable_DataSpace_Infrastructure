variable "kubernetes_local_path" {
  type        = string
  description = "The path to the kubeconfig file"
  default     = "~/.kube/config"
}

variable "namespace" {
  type        = string
  description = "Namespace for the DS operator deployment"
  default     = "ds-operator"
}

variable "ds_domain" {
  type        = string
  description = "Data Space domain"
  default     = "ds-operator.io"
}

# MongoDB service
variable "mongodb" {
  type = object({
    version       = string
    chart_name    = string
    repository    = string
    root_password = string
  })
  description = "MongoDB service"
  default = {
    version       = "11.0.4"
    chart_name    = "mongodb"
    repository    = "https://raw.githubusercontent.com/bitnami/charts/archive-full-index/bitnami"
    root_password = "admin"
  }
}

# MySQL database
variable "mysql" {
  type = object({
    version       = string
    chart_name    = string
    repository    = string
    root_password = string
    # Trusted Issuer List (TIL) database name | Credential Config Service (CCS) 
    # database name
    til_db = string
    ccs_db = string
  })
  description = "MySQL service"
  default = {
    version       = "9.4.4"
    chart_name    = "mysql"
    repository    = "https://raw.githubusercontent.com/bitnami/charts/archive-full-index/bitnami"
    root_password = "admin"
    til_db        = "til"
    ccs_db        = "ccs"
  }
}

# Orion-LD broker
variable "orion_ld" {
  type = object({
    version    = string
    chart_name = string
    repository = string
  })
  description = "Orion-LD service"
  default = {
    version    = "1.2.6"
    chart_name = "orion"
    repository = "https://fiware.github.io/helm-charts"
  }
}

# Credentials Config Service
variable "credentials_config_service" {
  type = object({
    version    = string
    chart_name = string
    repository = string
  })
  description = "Credentials Config Service"
  default = {
    version    = "0.0.4"
    chart_name = "credentials-config-service"
    repository = "https://fiware.github.io/helm-charts"
  }
}

# Trusted issuers list
variable "trusted_issuers_list" {
  type = object({
    version    = string
    chart_name = string
    repository = string
  })
  description = "Trusted Issuers List"
  default = {
    version    = "0.5.3"
    chart_name = "trusted-issuers-list"
    repository = "https://fiware.github.io/helm-charts"
  }
}

# Keyrock (Authorization Registry)
variable "keyrock" {
  type = object({
    version        = string
    chart_name     = string
    repository     = string
    admin_password = string
    admin_email    = string
  })
  description = "Keyrock"
  default = {
    version        = "0.7.5"
    chart_name     = "keyrock"
    repository     = "https://fiware.github.io/helm-charts"
    admin_password = "admin"
    admin_email    = "admin@ds-operator.org"
  }
}
