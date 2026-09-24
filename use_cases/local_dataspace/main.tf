module "trust_anchor" {
  source = "../../modules/fiware/trust_anchor"

  namespace          = var.namespace
  tailscale_hostname = var.tailscale_hostname
}
