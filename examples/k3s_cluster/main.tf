module "kubernetes_cluster" {
  source = "../../modules/k3s/"
  cluster_name = "k3s-cluster"
}
