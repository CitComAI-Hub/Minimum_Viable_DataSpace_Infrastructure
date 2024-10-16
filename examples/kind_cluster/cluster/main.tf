module "local_k8s_cluster" {
  source = "../../../modules/kind/cluster/"

  cluster_name          = var.cluster_name
  kubernetes_local_path = pathexpand(var.kubernetes_local_path)

  add_extra_ports = [
    {
      container_port = 80
      host_port      = 80
      protocol       = "TCP"
    },
    {
      container_port = 443
      host_port      = 443
      protocol       = "TCP"
    }
    # {
    #   container_port = 8080
    #   host_port      = 8080
    #   protocol       = "TCP"
    # },
  ]
}
