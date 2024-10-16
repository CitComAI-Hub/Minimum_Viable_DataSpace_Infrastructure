module "trust_anchor" {
  source = "../../modules/fiware_ds_connector/ds_trustAnchor/"

  namespace      = "ds-operator"
  service_domain = "ds-operator.local"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}

module "provider_a" {
  source     = "../../modules/fiware_ds_connector/ds_connector/"
  depends_on = [module.trust_anchor]

  namespace      = "provider-a"
  service_domain = "provider-a.local"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  # Services Configuration
  did = {
    port         = 3002,
    country      = "DE"
    state        = "SAXONY"
    locality     = "Dresden"
    organization = "M&P Operations Inc."
    common_name  = "www.mp-operation.org"
  }
}

module "consumer_a" {
  source     = "../../modules/fiware_ds_connector/ds_consumer/"
  depends_on = [module.trust_anchor, module.provider_a]

  namespace      = "consumer-a"
  service_domain = "consumer-a.local"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  did = {
    port         = 3001,
    country      = "BE"
    state        = "BRUSSELS"
    locality     = "Brussels"
    organization = "Fancy Marketplace Co."
    common_name  = "www.fancy-marketplace.biz"
  }
}