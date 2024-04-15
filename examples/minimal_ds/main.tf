#! Use makefile command to create a local k8s cluster.

locals {
  trust_anchor_domain = "ds-operator.local"
  tpr_domain = "tpr.${local.trust_anchor_domain}"
}

module "ca_configuration" {
  source              = "../../modules/ca_configuration/"
  count               = var.flags_deployment.ca_configuration ? 1 : 0 # count =: number of instances to create
  namespace           = "cert-manager"
  clusterissuer_name  = var.ca_clusterissuer_name
  secret_ca_container = "ca-cert-manager"
  providers = {
    kubernetes = kubernetes
  }
}

module "ds_operator" {
  source     = "../../modules/ds_operator/"
  depends_on = [module.ca_configuration]
  namespace  = "ds-operator"
  service_domain = local.trust_anchor_domain
  providers = {
    helm = helm
  }
  flags_deployment = {
    # trust anchor deployment
    mongodb                       = true
    orion_ld                      = true
    trusted_participants_registry = true # TODO: satellite CONFIGURATION
    # not needed
    mysql                      = false
    walt_id                    = false
    credentials_config_service = false
    trusted_issuers_list       = false
    verifier                   = false
    pdp                        = false
    kong                       = false
    portal                     = false
    keyrock                    = false
  }
}

module "connector_A" {
  source         = "../../modules/ds_connector/"
  depends_on     = [module.ca_configuration, module.ds_operator]
  namespace      = "ds-connector-a"
  service_domain = "ds-connector-a.local"
  trust_anchor_domain = local.tpr_domain
  providers = {
    helm = helm
  }
}
