output "secret_names" {
  description = "Names of the Kubernetes Secrets synced into the namespace"
  value       = [for name, _ in kubectl_manifest.external_secret : name]
}

output "service_account_name" {
  description = "ServiceAccount used by External Secrets to authenticate against Vault"
  value       = kubernetes_service_account.this.metadata[0].name
}
