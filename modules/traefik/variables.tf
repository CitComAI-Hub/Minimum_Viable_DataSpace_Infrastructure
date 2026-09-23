variable "namespace" {
  description = "Namespace de Kubernetes donde se desplegará Traefik"
  type        = string
  default     = "traefik"
}

variable "chart_version" {
  description = "Versión del Helm chart de Traefik (https://github.com/traefik/traefik-helm-chart/releases)"
  type        = string
  default     = "33.2.1" # Traefik v3.x
}

variable "dashboard_enabled" {
  description = "Habilita el dashboard de Traefik y lo expone vía IngressRoute"
  type        = bool
  default     = true
}

variable "dashboard_host" {
  description = "Host donde se expondrá el dashboard (sin tocar /etc/hosts, usa .localhost)"
  type        = string
  default     = "traefik.localhost"
}

variable "node_selector" {
  description = "NodeSelector para asignar Traefik al nodo control-plane etiquetado como ingress-ready"
  type        = map(string)
  default     = { "ingress-ready" = "true" }
}

variable "web_host_port" {
  description = "Puerto del host mapeado al puerto HTTP del contenedor Kind"
  type        = number
  default     = 80
}

variable "websecure_host_port" {
  description = "Puerto del host mapeado al puerto HTTPS del contenedor Kind"
  type        = number
  default     = 443
}

