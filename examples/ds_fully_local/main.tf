locals {
  kubernetes_path       = "~/.kube/config"
  ca_clusterissuer_name = "ca-certificates"
}

#! Use makefile command to create a local k8s cluster.


module "ca_configuration" {
  source = "../../modules/ca_configuration/"

  namespace           = "cert-manager"
  clusterissuer_name  = local.ca_clusterissuer_name
  secret_ca_container = "ca-cert-manager"
}

module "local_ds_operator" {
  source     = "../../modules/ds_operator/"
  depends_on = [module.ca_configuration]
  providers = {
    helm = helm
  }

  namespace = "ds-operator"
  flags_deployment = {
    mongodb = true
    mysql   = true
    walt_id = true
    # depends on: mongodb
    orion_ld = true
    # depends on: mysql
    keyrock                       = false
    credentials_config_service    = false
    trusted_participants_registry = false
    # depends on: credentials_config_service, wallet_id, trusted_issuers_list
    verifier = false
    # depends on: orion_ld
    kong                 = false
    trusted_issuers_list = false
    # depends on: keyrock, verifier
    pdp = false
  }
}
