output "tailscale_enabled" {
  description = "Indica si el módulo de Tailscale se ha desplegado"
  value       = length(module.tailscale) > 0
}

output "tailscale_traefik_url" {
  description = "URL en la Tailnet con TLS automático para Traefik"
  value       = length(kubernetes_ingress_v1.traefik_tailscale) > 0 ? "https://${var.tailscale_traefik_hostname}.<tu-tailnet>.ts.net/dashboard/" : "Tailscale Ingress no habilitado"
}
