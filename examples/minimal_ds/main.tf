#! Use makefile command to create a local k8s cluster.

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

module "connector_A" {
  source     = "../../modules/ds_connector/"
  depends_on = [module.ca_configuration]
  namespace  = "ds-connector"
  providers = {
    helm = helm
  }
}
