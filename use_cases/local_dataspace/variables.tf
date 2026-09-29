variable "kubeconfig_path" {
  description = "Ruta al kubeconfig generado por kind_cluster"
  type        = string
  default     = "../kind_cluster/cluster-config.yaml"
}

variable "ingress_class_name" {
  description = "IngressClass con la que se exponen los servicios (la crea el Tailscale Operator de kind_cluster/apps)"
  type        = string
  default     = "tailscale"
}

variable "tailnet_domain" {
  description = "Dominio MagicDNS de la Tailnet (p. ej. tail1234.ts.net), solo para mostrar las URLs completas en los outputs"
  type        = string
  default     = "<tu-tailnet>.ts.net"
}

variable "trust_anchor_namespace" {
  description = "Namespace del Trust Anchor"
  type        = string
  default     = "trust-anchor"
}

variable "trust_anchor_tir_hostname" {
  description = "Hostname de la API TIR (consulta de issuers) en la Tailnet"
  type        = string
  default     = "tir"
}

variable "trust_anchor_til_hostname" {
  description = "Hostname de la API TIL (registro de issuers) en la Tailnet"
  type        = string
  default     = "til"
}
