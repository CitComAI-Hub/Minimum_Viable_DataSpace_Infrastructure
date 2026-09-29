module "trust_anchor" {
  source = "../../modules/fiware/trust_anchor"

  namespace          = var.trust_anchor_namespace
  ingress_class_name = var.ingress_class_name
  tir_hostname       = var.trust_anchor_tir_hostname
  til_hostname       = var.trust_anchor_til_hostname
}
