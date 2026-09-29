output "namespace" {
  description = "Namespace where Vault is deployed (consumers register there)"
  value       = helm_release.vault.namespace
}

output "internal_address" {
  description = "In-cluster address of Vault, for calls from other pods"
  value       = "http://vault.${helm_release.vault.namespace}.svc.cluster.local:8200"
}

output "hostname" {
  description = "Hostname of the Vault Ingress (null when there is no Ingress)"
  value       = var.ingress_enabled ? var.hostname : null
}
output "root_token_command" {
  description = "Command that prints the root token to log into the UI (created by the bootstrap)"
  value       = "kubectl -n ${helm_release.vault.namespace} get secret vault-init -o jsonpath='{.data.init_json}' | base64 -d | jq -r .root_token"
}

# The bootstrap Deployment is only Ready once Vault is unsealed and configured, so
# depending on this output means depending on a usable Vault.
output "ready" {
  description = "Id of the bootstrap Deployment; depend on it to wait for a usable Vault"
  value       = kubernetes_deployment_v1.bootstrap.id
}
