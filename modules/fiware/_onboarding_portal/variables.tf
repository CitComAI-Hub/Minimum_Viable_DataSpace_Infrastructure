variable "namespace" {
  description = "Namespace de Kubernetes donde se desplegará el portal"
  type        = string
  default     = "onboarding"
}

variable "name" {
  description = "Nombre base de los recursos del portal"
  type        = string
  default     = "onboarding-portal"
}

variable "release_name" {
  description = "Nombre del release Helm del portal"
  type        = string
  default     = "onboarding-portal"
}

variable "chart" {
  description = "Chart FIWARE del Onboarding Portal"
  type = object({
    name       = string
    repository = string
    version    = string
  })
  default = {
    name       = "onboarding-portal"
    repository = "https://fiware.github.io/helm-charts"
    version    = "1.4.3"
  }
}

variable "keycloak_chart" {
  description = "Chart Data Space Connector usado para desplegar Keycloak"
  type = object({
    name       = string
    repository = string
    version    = string
  })
  default = {
    name       = "data-space-connector"
    repository = "https://fiware.github.io/data-space-connector"
    version    = "10.8.0"
  }
}

variable "keycloak_release_name" {
  description = "Nombre del release Helm del Data Space Connector"
  type        = string
  default     = "data-space-connector"
}

variable "keycloak_realm" {
  description = "Realm de Keycloak usado por el portal"
  type        = string
  default     = "onboarding"
}

variable "keycloak_tailscale_hostname" {
  description = "Hostname de Keycloak dentro de la Tailnet"
  type        = string
  default     = "keycloak"
}

variable "keycloak_public_url" {
  description = "URL pública de Keycloak usada por el realm y los redireccionamientos OIDC"
  type        = string
  default     = "https://keycloak.<tu-tailnet>.ts.net"
}

variable "onboarding_public_url" {
  description = "URL pública del portal usada en los redirect URIs de Keycloak"
  type        = string
  default     = "https://onboarding.<tu-tailnet>.ts.net"
}

variable "keycloak_admin_password" {
  description = "Password del usuario administrador de Keycloak"
  type        = string
  sensitive   = true
  default     = "change-me-keycloak-admin"
}

variable "onboarding_client_secret" {
  description = "Secret del cliente OIDC del portal"
  type        = string
  sensitive   = true
  default     = "change-me-onboarding-client"
}

variable "keycloak_store_password" {
  description = "Password del almacén usado por Keycloak"
  type        = string
  sensitive   = true
  default     = "change-me-keycloak-store"
}

variable "postgres_password" {
  description = "Password del usuario PostgreSQL local de onboarding"
  type        = string
  sensitive   = true
  default     = "change-me-postgres"
}

variable "postgres_storage_size" {
  description = "Tamaño del PVC de PostgreSQL local"
  type        = string
  default     = "2Gi"
}
variable "keycloak_extra_values" {
  description = "Ficheros YAML adicionales para el chart Data Space Connector"
  type        = list(string)
  default     = []
}

variable "replicas" {
  description = "Número de réplicas del portal"
  type        = number
  default     = 1
}

variable "config" {
  description = "Configuración interna del portal, equivalente a config en values.yaml"
  type        = any
  default     = {}
}

variable "secrets" {
  description = "Mapeo de Secrets existentes para database, login y keycloak"
  type        = any
  default     = {}
}

variable "extra_env_vars" {
  description = "Variables de entorno adicionales del chart"
  type        = list(any)
  default     = []
}

variable "service_port" {
  description = "Puerto del Service de Kubernetes"
  type        = number
  default     = 80
}

variable "persistence_enabled" {
  description = "Habilita el almacenamiento persistente para los archivos subidos"
  type        = bool
  default     = true
}

variable "persistence_size" {
  description = "Tamaño del volumen persistente para /app/files"
  type        = string
  default     = "5Gi"
}

variable "storage_class_name" {
  description = "StorageClass del PVC; vacío usa la clase por defecto del clúster"
  type        = string
  default     = ""
}

variable "tailscale_enabled" {
  description = "Expone el portal mediante el Ingress Controller de Tailscale"
  type        = bool
  default     = false
}

variable "tailscale_hostname" {
  description = "Nombre DNS del portal dentro de la Tailnet"
  type        = string
  default     = "onboarding"
}

variable "extra_values" {
  description = "Ficheros YAML adicionales para sobrescribir valores del chart"
  type        = list(string)
  default     = []
}
