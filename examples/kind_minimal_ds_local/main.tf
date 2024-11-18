locals {
  operator_namespace   = "ds-operator"
  provider_a_namespace = "provider-a"
  consumer_a_namespace = "consumer-a"
}

module "trust_anchor" {
  source = "../../modules/fiware_ds_connector/ds_trustAnchor/"

  namespace      = local.operator_namespace
  service_domain = "${local.operator_namespace}.local"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}

module "provider_a" {
  source     = "../../modules/fiware_ds_connector/ds_connector/"
  depends_on = [module.trust_anchor]

  namespace      = local.provider_a_namespace
  service_domain = "${local.provider_a_namespace}.local"

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

  operator_namespace = local.operator_namespace
  provider_namespace = local.provider_a_namespace
  namespace          = local.consumer_a_namespace
  service_domain     = "${local.consumer_a_namespace}.local"

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
