output "fqdn" {
  description = "Tailnet name reachable from the cluster"
  value       = var.fqdn
  depends_on  = [kubernetes_service.this]
}
