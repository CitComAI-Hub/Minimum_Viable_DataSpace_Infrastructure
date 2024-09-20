module "cert_trust_manager" {
  source     = "../../../modules/cert_trust_manager"

  providers = {
    kubectl    = kubectl
    kubernetes = kubernetes
    helm       = helm
  }
}
