output "tailscale_operator_hostname" {
  description = "Nombre del operador en la Tailnet"
  value       = module.tailscale.operator_hostname
}

output "ingress_class_name" {
  description = "IngressClass a usar para exponer servicios por HTTPS en la Tailnet"
  value       = module.tailscale.ingress_class_name
}
