module "trust_anchor" {
  source    = "../../../modules/fiware_ds_connector/ds_connector/"
  namespace = "ds-connector-a"
  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}
