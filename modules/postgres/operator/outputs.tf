output "namespace" {
  description = "Namespace of the CloudNativePG operator"
  value       = helm_release.cnpg.namespace
}

output "chart_version" {
  description = "Installed cloudnative-pg chart version"
  value       = helm_release.cnpg.version
}
