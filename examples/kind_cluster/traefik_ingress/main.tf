module "local_k8s_cluster" {
  source = "../../../modules/kind/traefik-ingress/"

  cluster_name          = var.cluster_name
  kubernetes_local_path = pathexpand(var.kubernetes_local_path)
  namespace = "traefik-ingress"

  providers = {
    kubernetes = kubernetes
  }
}
