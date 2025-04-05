################################################################################
# Kubernetes cluster                                                           #
################################################################################
variable "kubernetes_local_path" {
  type        = string
  description = "The path to the kubeconfig file"
  default     = "~/.kube/config"
}

variable "namespace" {
  type        = string
  description = "Namespace for the DS operator deployment"
  default     = "ds-trust-anchor"
}

variable "service_domain" {
  type        = string
  description = "Data Space domain"
  default     = "ds-trust-anchor.local"
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
variable "trust_anchor" {
  type = object({
    version    = string
    chart_name = string
    repository = string
  })
  description = "Fiware minimal Trust Anchor (DS Operator)"
  default = {
    version    = "0.2.0"
    chart_name = "trust-anchor"
    repository = "https://fiware.github.io/data-space-connector/"
  }
}

variable "enable_ingress" {
  type        = map(bool)
  description = "Enable ingress for the DS Trust Anchor"
  default = {
    til = true
    tir = true
  }
}

variable "enable_ingress_tls" {
  type        = map(bool)
  description = "Enable ingress TLS for the DS operator (trust anchor)"
  default = {
    til = false
    tir = false
  }
}

variable "enable_services" {
  type        = map(bool)
  description = "Enable services for the DS Trust Anchor"
  default = {
    generate_passwords = true
    mysql              = true
    til                = true
  }
}

variable "services_names" {
  type        = map(string)
  description = "Services names for the DS Operator"
  default = {
    trust_anchor = "fiware-minimal-trust-anchor"
    mysql        = "mysql"
    til          = "trusted-issuers-list"
    tir          = "trusted-issuers-registry"
  }
}

################################################################################
# Services Configuration                                                       #
################################################################################
variable "trusted_issuers_list" {
  type = object({
    port = number
  })
  description = "Trusted Issuers List configuration"
  default = {
    port = 8080
  }
}

variable "mysql" {
  type        = map(string)
  description = "MySQL configuration"
  default = {
    db_name_til   = "tirdb"
    username_root = "root"
    secret        = "mysql-database-secret"
    secret_key    = "mysql-root-password"
  }
}
