variable "name" {
  description = "Name of the PostgreSQL instance, unique in its namespace. Its read-write Service is <name>-rw"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.name)) && length(var.name) <= 40
    error_message = "name must be a lowercase DNS label of at most 40 characters."
  }
}

variable "namespace" {
  description = "Namespace of the instance. It must already exist; several instances can share it"
  type        = string
}

variable "type" {
  description = "Flavour of the instance: \"postgresql\", or \"postgis\" for geospatial workloads (e.g. an NGSI-LD broker)"
  type        = string
  default     = "postgresql"

  validation {
    condition     = contains(["postgresql", "postgis"], var.type)
    error_message = "type must be \"postgresql\" or \"postgis\"."
  }
}

variable "postgresql_version" {
  description = "PostgreSQL major version"
  type        = string
  default     = "17"
}

variable "postgis_version" {
  description = "PostGIS version, only used when type is \"postgis\""
  type        = string
  default     = "3.5"
}

variable "instances" {
  description = "Number of PostgreSQL instances (1 primary + replicas)"
  type        = number
  default     = 1
}

variable "storage_size" {
  description = "Size of the data volume of each instance"
  type        = string
  default     = "5Gi"
}

variable "storage_class" {
  description = "StorageClass of the data volumes (null = cluster default)"
  type        = string
  default     = null
}

variable "chart_version" {
  description = "cloudnative-pg cluster chart version (https://github.com/cloudnative-pg/charts)"
  type        = string
  default     = "0.8.1"
}

variable "client_image" {
  description = "Image with pg_isready, used to wait until the instance accepts connections"
  type        = string
  default     = "postgres:17-alpine"
}

variable "vault_namespace" {
  description = "Namespace where Vault is deployed (output namespace of modules/vault)"
  type        = string
  default     = "vault"
}

variable "vault_address" {
  description = "In-cluster address of Vault (output internal_address of modules/vault)"
  type        = string
  default     = "http://vault.vault.svc.cluster.local:8200"
}
