output "tailscale_operator_hostname" {
  description = "Operator device name in the Tailnet"
  value       = module.tailscale.operator_hostname
}

output "ingress_class_name" {
  description = "IngressClass used to expose services over HTTPS in the Tailnet"
  value       = module.tailscale.ingress_class_name
}

output "ingress_annotations" {
  description = "Annotations every Ingress must carry to be served by the Tailscale ProxyGroup"
  value       = module.tailscale.ingress_annotations
}

output "tailscale_letsencrypt_staging" {
  description = "Whether the HTTPS certificates of the Tailnet services come from Let's Encrypt staging (not publicly trusted)"
  value       = module.tailscale.letsencrypt_staging
}

output "vault_ui_url" {
  description = "Vault UI in the Tailnet"
  value       = "https://${module.vault.hostname}.${var.tailnet_domain}"
}

output "vault_internal_address" {
  description = "In-cluster address of Vault, for calls from other pods"
  value       = module.vault.internal_address
}

output "vault_root_token_command" {
  description = "Command that prints the Vault root token"
  value       = "export KUBECONFIG='${abspath(var.kubeconfig_path)}' && ${module.vault.root_token_command}"
}

output "dataspace_postgres_host" {
  description = "In-cluster hostname of the shared PostgreSQL instance of the data space services"
  value       = module.dataspace_postgres.host
}
