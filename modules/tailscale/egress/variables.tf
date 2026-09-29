variable "name" {
  description = "Name of the ExternalName Service"
  type        = string
}

variable "namespace" {
  description = "Namespace of the Service. Any namespace works: the name resolves cluster-wide"
  type        = string
}

variable "fqdn" {
  description = "Tailnet name that pods must reach (e.g. keycloak.tail1234.ts.net)"
  type        = string
}

variable "ports" {
  description = "TCP ports reachable on that name"
  type        = list(number)
  default     = [443]
}

variable "proxy_group" {
  description = "Egress ProxyGroup (output egress_proxy_group_name of modules/tailscale)"
  type        = string
  default     = "egress"
}
