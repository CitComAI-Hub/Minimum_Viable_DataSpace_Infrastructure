module "local_k8s_cluster" {
  source = "../../modules/kind"

  cluster_name    = var.cluster_name
  kubeconfig_path = pathexpand(var.kubernetes_local_path)

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
  ]
}

