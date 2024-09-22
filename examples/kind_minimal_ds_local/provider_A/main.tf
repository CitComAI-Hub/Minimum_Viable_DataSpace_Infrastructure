module "trust_anchor" {
  source         = "../../../modules/fiware_ds_connector/ds_connector/"
  namespace      = "provider-a"
  service_domain = "provider-a.local"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}
