locals {
  kubernetes_path = "~/.kube/config"
}

module "local_k8s_cluster" {
  source = "../../modules/kind_cluster"

  kubernetes_local_path = local.kubernetes_path
  path_module           = "../../modules/kind_cluster"
  cluster_name          = "ds-local-cluster"
}

module "portainerce_docker" {
  source     = "../../modules/portainer_ce/"
  depends_on = [module.local_k8s_cluster]

  img_version = "2.19.4"
}

module "local_ds_operator" {
  source     = "../../modules/ds_operator/"
  depends_on = [module.local_k8s_cluster]
  providers = {
    helm = helm
  }

  namespace = "ds-operator"
}
