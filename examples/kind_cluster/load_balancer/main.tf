module "local_k8s_cluster" {
  source = "../../../modules/kind/metal_lb/"

  cluster_name          = var.cluster_name
  kubernetes_local_path = pathexpand(var.kubernetes_local_path)
}
