module "trust_anchor" {
  source    = "../../../modules/fiware_ds_connector/ds_trustAnchor/"
  namespace = "ds-operator"
  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}
