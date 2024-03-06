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

variable "flags_deployment" {
  type = object({
    mongodb = bool
    mysql   = bool
    walt_id = bool
    # depends on: mongodb
    orion_ld = bool
    # depends on: mysql
    keyrock                    = bool
    credentials_config_service = bool
    trusted_issuers_list       = bool
    # depends on: walt_id, credentials_config_service, trusted_issuers_list
    verifier = bool
    # depends on: orion_ld
    kong                          = bool
    trusted_participants_registry = bool
    # depends on: keyrock, verifier
    pdp = bool
  })
  description = "Whether to deploy resources."
  default = {
    mongodb = true
    mysql   = true
    walt_id = true
    # depends on: mongodb
    orion_ld = true
    # depends on: mysql
    keyrock                       = true
    credentials_config_service    = true
    trusted_participants_registry = true
    # depends on: walt_id, credentials_config_service, trusted_issuers_list
    verifier = true
    # depends on: orion_ld
    kong                 = true
    trusted_issuers_list = true
    # depends on: keyrock, verifier
    pdp = true
  }
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

# Trusted Participants Registry
variable "trusted_participants_registry" {
  type = object({
    version    = string
    chart_name = string
    repository = string
  })
  description = "Trusted Participants Registry Service"
  default = {
    version    = "0.0.3"
    chart_name = "trusted-issuers-registry"
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

# PDP
variable "pdp" {
  type = object({
    version    = string
    chart_name = string
    repository = string
  })
  description = "PDP Service"
  default = {
    version    = "0.0.16"
    chart_name = "dsba-pdp"
    repository = "https://fiware.github.io/helm-charts"
  }

}

# Kong
variable "kong" {
  type = object({
    version    = string
    chart_name = string
    repository = string
  })
  description = "Kong Service"
  default = {
    version    = "2.8.0"
    chart_name = "kong"
    repository = "https://charts.konghq.com"
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
  description = "Trusted Issuers List service"
  default = {
    version    = "0.5.3"
    chart_name = "trusted-issuers-list"
    repository = "https://fiware.github.io/helm-charts"
  }
}

# Walt-ID
variable "walt_id" {
  type = object({
    version    = string
    chart_name = string
    repository = string
  })
  description = "Walt-ID Service"
  default = {
    version    = "0.0.17"
    chart_name = "vcwaltid"
    repository = "https://i4Trust.github.io/helm-charts"
  }
}

# Verifier
variable "verifier" {
  type = object({
    version    = string
    chart_name = string
    repository = string
  })
  description = "Verifier Service"
  default = {
    version    = "1.0.15"
    chart_name = "vcverifier"
    repository = "https://i4Trust.github.io/helm-charts"
  }
}

# Portal
variable "portal" {
  type = object({
    version    = string
    chart_name = string
    repository = string
  })
  description = "Portal Service"
  default = {
    version    = "0.0.5"
    chart_name = "vcportal"
    repository = "https://i4Trust.github.io/helm-charts"
  }

}
