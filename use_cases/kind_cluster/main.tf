module "local_k8s_cluster" {
  source = "../../modules/kind"

  cluster_name    = var.cluster_name
  kubeconfig_path = pathexpand(var.kubernetes_local_path)

  # No host ports: all traffic comes in through the Tailscale Ingresses
  add_extra_ports = []
}
