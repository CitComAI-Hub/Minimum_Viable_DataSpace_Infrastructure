variable "namespace" {
  description = "Kubernetes namespace where Traefik is deployed"
  type        = string
  default     = "traefik"
}

variable "chart_version" {
  description = "Traefik Helm chart version (https://github.com/traefik/traefik-helm-chart/releases)"
  type        = string
  default     = "33.2.1" # Traefik v3.x
}

variable "dashboard_enabled" {
  description = "Enables the Traefik dashboard and exposes it through an IngressRoute"
  type        = bool
  default     = true
}

variable "node_selector" {
  description = "NodeSelector that pins Traefik to the control-plane node labelled ingress-ready"
  type        = map(string)
  default     = { "ingress-ready" = "true" }
}

variable "web_host_port" {
  description = "Host port mapped to the HTTP port of the Kind container"
  type        = number
  default     = 80
}

variable "websecure_host_port" {
  description = "Host port mapped to the HTTPS port of the Kind container"
  type        = number
  default     = 443
}

