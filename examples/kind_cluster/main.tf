module "local_k8s_cluster" {
  source = "../../modules/kind_cluster/"

  path_module      = "../../modules/kind_cluster"
  cluster_name     = var.cluster_name
  add_extra_mounts = var.add_extra_mounts
}

module "portainerce_docker" {
  source     = "../../modules/portainer_ce/"
  depends_on = [module.local_k8s_cluster]

  img_version = "2.19.4"
}
