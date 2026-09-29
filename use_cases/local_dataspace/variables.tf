variable "kubeconfig_path" {
  description = "Path to the kubeconfig written by kind_cluster"
  type        = string
  default     = "../kind_cluster/cluster-config.yaml"
}

variable "ingress_class_name" {
  description = "IngressClass used to expose the services (created by the Tailscale Operator in kind_cluster/apps)"
  type        = string
  default     = "tailscale"
}

variable "tailnet_domain" {
  description = "MagicDNS domain of the Tailnet (e.g. tail1234.ts.net), only used to print full URLs in the outputs"
  type        = string
  default     = "<your-tailnet>.ts.net"
}

variable "trust_anchor_namespace" {
  description = "Trust Anchor namespace"
  type        = string
  default     = "trust-anchor"
}

variable "trust_anchor_tir_hostname" {
  description = "Tailnet hostname of the TIR API (issuer lookup)"
  type        = string
  default     = "tir"
}

variable "trust_anchor_til_hostname" {
  description = "Tailnet hostname of the TIL API (issuer registration)"
  type        = string
  default     = "til"
}
