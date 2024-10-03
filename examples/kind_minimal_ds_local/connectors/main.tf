module "consumer_connector_a" {
  source         = "../../../modules/fiware_ds_connector/ds_consumer/"
  namespace      = "consumer-a"
  service_domain = "consumer-a.local"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}

module "provider_connector_a" {
  source         = "../../../modules/fiware_ds_connector/ds_connector/"
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
