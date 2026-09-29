# Every output depends on the provisioning Job, so whatever uses them waits until
# the database exists and the credentials Secret is in the service namespace.

output "host" {
  description = "In-cluster hostname of PostgreSQL"
  value       = var.postgres_host
  depends_on  = [kubernetes_job_v1.provision, module.client_credentials]
}

output "port" {
  description = "PostgreSQL port"
  value       = var.postgres_port
  depends_on  = [kubernetes_job_v1.provision, module.client_credentials]
}

output "database" {
  description = "Name of the database"
  value       = var.database
  depends_on  = [kubernetes_job_v1.provision, module.client_credentials]
}

output "username" {
  description = "Owner role of the database"
  value       = local.username
  depends_on  = [kubernetes_job_v1.provision, module.client_credentials]
}

output "secret_name" {
  description = "Secret in the service namespace with the keys username and password"
  value       = module.client_credentials.secret_names[0]
  depends_on  = [kubernetes_job_v1.provision]
}

output "password_key" {
  description = "Key of the password in the credentials Secret"
  value       = "password"
}
