output "tailscale_operator_hostname" {
  description = "Operator device name in the Tailnet"
  value       = module.tailscale.operator_hostname
}

output "ingress_class_name" {
  description = "IngressClass used to expose services over HTTPS in the Tailnet"
  value       = module.tailscale.ingress_class_name
}
