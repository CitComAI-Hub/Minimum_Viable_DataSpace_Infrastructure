module "portainer" {
  source = "../../../modules/portainer_ce"

  cluster_name          = var.cluster_name
  kubernetes_local_path = pathexpand(var.kubernetes_local_path)
  img_version           = "2.19.4"

  providers = {
    kubectl = kubectl
  }
}
