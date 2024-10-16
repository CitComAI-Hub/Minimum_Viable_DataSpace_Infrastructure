module "ca_configuration" {
  source              = "../../../modules/ca_configuration/"
  namespace           = "cert-manager"
  clusterissuer_name  = var.ca_clusterissuer_name
  secret_ca_container = "ca-cert-manager"

  providers = {
    kubernetes = kubernetes
  }
}
