variable "kubeconfig_path" {
  description = "Ruta al kubeconfig generado por la capa de cluster (kind_cluster/cluster-config.yaml)"
  type        = string
  default     = "../cluster-config.yaml"
}

variable "tailscale_oauth_client_id" {
  description = "Tailscale OAuth Client ID"
  type        = string
  sensitive   = true
  # default     = ""
}

variable "tailscale_oauth_client_secret" {
  description = "Tailscale OAuth Client Secret"
  type        = string
  sensitive   = true
  # default     = ""
}

variable "enable_tailscale" {
  description = "Habilitar el despliegue del Tailscale Operator"
  type        = bool
  default     = true
}

variable "tailscale_expose_traefik" {
  description = "Exponer Traefik vía Tailscale Ingress para obtener HTTPS y dominio automático"
  type        = bool
  default     = true
}

variable "tailscale_traefik_hostname" {
  description = "Nombre de máquina en la Tailnet para Traefik (ej: 'traefik' -> https://traefik.<tailnet>.ts.net)"
  type        = string
  default     = "traefik"
}
