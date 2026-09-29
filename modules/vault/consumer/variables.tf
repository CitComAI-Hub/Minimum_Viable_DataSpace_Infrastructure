variable "name" {
  description = "Consumer name, unique in the cluster. Names the Vault role/policy (eso-<name>) and the ServiceAccount"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.name)) && length(var.name) <= 50
    error_message = "name must be a lowercase DNS label of at most 50 characters."
  }
}

variable "namespace" {
  description = "Namespace of the service; the Kubernetes Secrets are created there. It must already exist"
  type        = string
}

variable "secrets" {
  description = <<-EOT
    Kubernetes Secrets the service needs, keyed by Secret name. Each one is synced from a Vault path:
    - vault_path: path under the secret/ KV v2 engine (e.g. "postgres/til")
    - static: fixed values (e.g. username), always applied
    - generated_fields: fields randomly generated inside the cluster the first time and never rotated
    - type: type of the Kubernetes Secret (e.g. kubernetes.io/basic-auth)
    Two consumers can share a vault_path (e.g. a database and its client) with the same definition.
  EOT
  type = map(object({
    vault_path       = string
    static           = optional(map(string), {})
    generated_fields = optional(list(string), [])
    type             = optional(string, "Opaque")
  }))
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

variable "refresh_interval" {
  description = "How often External Secrets re-reads the values from Vault"
  type        = string
  default     = "1h"
}

variable "wait_for_secrets" {
  description = "Waits until every Kubernetes Secret has been synced from Vault, so services depending on this module start with their secrets in place"
  type        = bool
  default     = true
}
