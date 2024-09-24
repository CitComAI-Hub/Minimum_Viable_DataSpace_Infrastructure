module "local_k8s_cluster" {
  source = "../../../modules/kind/traefik_ingress/"

  # cluster_name          = var.cluster_name
  kubernetes_local_path = pathexpand(var.kubernetes_local_path)

  providers = {
    helm = helm
  }
}
