module "trust_anchor" {
  source    = "../../../modules/fiware_ds_connector/ds_connector/"
  namespace = "provider-a"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}
