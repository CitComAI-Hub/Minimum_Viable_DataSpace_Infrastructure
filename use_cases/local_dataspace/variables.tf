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

variable "ingress_annotations" {
  description = "Annotations every Ingress must carry to be served by the Tailscale ProxyGroup (output ingress_annotations of kind_cluster/apps)"
  type        = map(string)
  default = {
    "tailscale.com/proxy-group" = "ingress"
  }
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
