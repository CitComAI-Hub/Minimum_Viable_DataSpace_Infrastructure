locals {
  local_domain       = "local"
  operator_namespace = "ds-operator"
  consumer_namespace = "consumer-a"

  operator_services_names = {
    trust_anchor = "fiware-minimal-trust-anchor"
    mysql        = "mysql"
    til          = "trusted-issuers-list"
    tir          = "trusted-issuers-registry"
  }

}

module "trust_anchor" {
  source = "../../modules/fiware/trust_anchor/"

  namespace      = local.operator_namespace
  service_domain = "${local.operator_namespace}.${local.local_domain}"
  services_names = local.operator_services_names

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}

module "consumer" {
  source     = "../../modules/fiware/ds_connector/consumer/"
  depends_on = [module.trust_anchor]

  operator_namespace = local.operator_namespace
  namespace          = local.consumer_namespace
  service_domain     = "${local.consumer_namespace}.${local.local_domain}"

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

