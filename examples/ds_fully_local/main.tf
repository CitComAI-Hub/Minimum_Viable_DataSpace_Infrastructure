locals {
  kubernetes_path = "~/.kube/config"
}

#! Use makefile command to create a local k8s cluster.

module "local_ds_operator" {
  source = "../../modules/ds_operator/"
  providers = {
    helm = helm
  }

  namespace = "ds-operator"
  flags_deployment = {
    mongodb = true
    mysql   = true
    walt_id = true
    # depends on: mysql
    keyrock                       = true
    credentials_config_service    = true
    trusted_participants_registry = true
    # depends on: mongodb
    orion_ld = true
    # depends on: credentials_config_service, wallet_id, trusted_issuers_list
    verifier = true
    # depends on: orion_ld
    kong                 = true
    trusted_issuers_list = true
    # depends on: keyrock, verifier
    pdp = true
  }
}
