locals {
  local_domain       = "local"
  operator_namespace = "ds-operator"
  consumer_namespace = "consumer-a"
  provider_namespace = "provider-a"


  operator_services_names = {
    trust_anchor = "fiware-minimal-trust-anchor"
    mysql        = "mysql"
    til          = "trusted-issuers-list"
    tir          = "trusted-issuers-registry"
  }

  provider_expose_services = {
    apisix = true
    # Below services are not exposed (ingress) by default (only for testing purposes)
    ccs     = true
    til     = true
    tir     = false
    did     = true
    vcv     = true
    pap     = true
    scorpio = true
    tmf_api = true
    rainbow = true
  }

  provider_services_names = {
    connector      = "fiware-data-space-connector"
    mysql          = "mysql-db"
    ccs            = "credentials-config-service"
    til            = "trusted-issuers-list"
    did            = "did-helper" # default name, not editable
    vcv            = "vc-verifier"
    postgresql     = "postgresql-db"
    pap            = "pap-odrl"
    apisix_service = "apisix-proxy"
    apisix_api     = "apisix-api"
    postgis        = "postgis-db"
    scorpio        = "scorpio-broker"
    tmf_api        = "tm-forum-api"
    cm             = "contract-management"
    rainbow        = "rainbow"
    tpp_data       = "tpp-rainbow-data"
    tpp_service    = "tpp-rainbow-service"
    tpp_catalog    = "tpp-rainbow-catalog"
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
  source = "../../modules/fiware/ds_connector/consumer/"

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

module "provider" {
  source = "../../modules/fiware/ds_connector/provider/"

  namespace      = local.provider_namespace
  service_domain = "${local.provider_namespace}.${local.local_domain}"
  services_names = local.provider_services_names
  enable_ingress = local.provider_expose_services

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
