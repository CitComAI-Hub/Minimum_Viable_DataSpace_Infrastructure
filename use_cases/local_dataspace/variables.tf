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
  description = "MagicDNS domain of the Tailnet (e.g. tail1234.ts.net). null = taken from the ConfigMap tailscale/tailnet published by kind_cluster/apps"
  type        = string
  default     = null
}

variable "egress_proxy_group" {
  description = "Egress ProxyGroup that lets pods reach Tailnet names (output egress_proxy_group_name of kind_cluster/apps)"
  type        = string
  default     = "egress"
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

variable "onboarding_namespace" {
  description = "Namespace of Keycloak and the onboarding portal"
  type        = string
  default     = "onboarding"
}

variable "keycloak_hostname" {
  description = "Tailnet hostname of the Keycloak of the onboarding"
  type        = string
  default     = "onboarding-admin"
}

variable "onboarding_hostname" {
  description = "Tailnet hostname of the onboarding portal"
  type        = string
  default     = "onboarding"
}

variable "agreement_document_path" {
  description = "PDF that applicants must sign (null = the sample shipped with modules/fiware/onboarding)"
  type        = string
  default     = null
}
