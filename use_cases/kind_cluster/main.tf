module "local_k8s_cluster" {
  source = "../../modules/kind"

  cluster_name    = var.cluster_name
  kubeconfig_path = pathexpand(var.kubernetes_local_path)

  # Sin puertos en el host: todo el tráfico entra por los Ingress de Tailscale
  add_extra_ports = []
}
