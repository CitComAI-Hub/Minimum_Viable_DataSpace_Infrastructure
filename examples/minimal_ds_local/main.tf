#! Use makefile command to create a local k8s cluster.

# locals {
#   trust_anchor_domain = "ds-operator.local"
#   tpr_domain          = "tpr.${local.trust_anchor_domain}"
# }

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

module "trust_anchor" {
  source     = "../../modules/ds_trustAnchor/"
  depends_on = [module.ca_configuration]
  namespace  = "ds-operator"
  providers = {
    helm = helm
  }
}
