output "namespace" {
  description = "Namespace where the Tailscale Operator is deployed"
  value       = kubernetes_namespace.tailscale.metadata[0].name
}

output "operator_name" {
  description = "Helm release name of the operator"
  value       = helm_release.tailscale_operator.name
}

output "ingress_class_name" {
  description = "IngressClass for Kubernetes Ingress resources exposed through Tailscale with automatic TLS"
  value       = "tailscale"
}

output "ingress_annotations" {
  description = "Annotations every Ingress must carry to be served by the ProxyGroup"
  value = {
    "tailscale.com/proxy-group" = var.proxy_group_name
  }
  # Referencing this output waits for a ready ProxyGroup
  depends_on = [kubectl_manifest.proxy_group]
}

output "chart_version" {
  description = "Installed Helm chart version"
  value       = helm_release.tailscale_operator.version
}

output "operator_hostname" {
  description = "Device name of the operator in the Tailnet"
  value       = var.operator_hostname
}

output "proxy_group_hostname_prefix" {
  description = "Prefix of the ProxyGroup device names in the Tailnet"
  value       = var.proxy_group_hostname_prefix
}

output "letsencrypt_staging" {
  description = "Whether Ingress certificates come from Let's Encrypt staging (not publicly trusted)"
  value       = var.letsencrypt_staging
}
