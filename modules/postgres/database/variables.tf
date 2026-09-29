variable "name" {
  description = "Short name of the service owning the database, unique in the cluster. Names the Kubernetes and Vault resources"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.name)) && length(var.name) <= 40
    error_message = "name must be a lowercase DNS label of at most 40 characters."
  }
}

variable "namespace" {
  description = "Namespace of the service; the credentials Secret is created there. It must already exist"
  type        = string
}

variable "database" {
  description = "Name of the database to create"
  type        = string

  validation {
    condition     = can(regex("^[a-z_][a-z0-9_]*$", var.database))
    error_message = "database must be a lowercase SQL identifier."
  }
}

variable "username" {
  description = "Owner role of the database (null = same as database)"
  type        = string
  default     = null

  validation {
    condition     = var.username == null || can(regex("^[a-z_][a-z0-9_]*$", var.username))
    error_message = "username must be a lowercase SQL identifier."
  }
}

variable "secret_name" {
  description = "Name of the Secret created in the service namespace, with the keys username and password (null = <name>-postgres-credentials)"
  type        = string
  default     = null
}

variable "extensions" {
  description = "Extensions created in the database by the superuser (e.g. [\"postgis\"] on a postgis instance)"
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for e in var.extensions : can(regex("^[a-z_][a-z0-9_]*$", e))])
    error_message = "extensions must be lowercase SQL identifiers."
  }
}

variable "postgres_namespace" {
  description = "Namespace of the PostgreSQL instance (output namespace of modules/postgres)"
  type        = string
  default     = "databases"
}

variable "postgres_host" {
  description = "In-cluster hostname of the PostgreSQL instance (output host of modules/postgres)"
  type        = string
  default     = "dataspace-rw.databases.svc.cluster.local"
}

variable "postgres_port" {
  description = "PostgreSQL port (output port of modules/postgres)"
  type        = number
  default     = 5432
}

variable "admin_secret_name" {
  description = "Secret with the superuser credentials in the PostgreSQL namespace (output admin_secret_name of modules/postgres)"
  type        = string
  default     = "dataspace-superuser"
}

variable "image" {
  description = "Image with psql used by the provisioning Job"
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
