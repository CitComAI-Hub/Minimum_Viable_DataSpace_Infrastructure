output "name" {
  description = "Name of the PostgreSQL instance"
  value       = var.name
}

output "namespace" {
  description = "Namespace of the PostgreSQL instance"
  value       = var.namespace
}

output "type" {
  description = "Flavour of the instance (postgresql or postgis)"
  value       = var.type
}

# host and port depend on the readiness Job, so whatever uses them waits for an
# instance that accepts connections

output "host" {
  description = "In-cluster hostname of the read-write Service"
  value       = local.host
  depends_on  = [kubernetes_job_v1.wait_ready]
}

output "port" {
  description = "PostgreSQL port"
  value       = 5432
  depends_on  = [kubernetes_job_v1.wait_ready]
}

output "admin_secret_name" {
  description = "Secret with the superuser credentials, only available in the instance namespace"
  value       = local.superuser_secret_name
}
