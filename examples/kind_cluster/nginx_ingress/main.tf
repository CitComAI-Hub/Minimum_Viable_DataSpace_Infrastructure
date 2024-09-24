module "local_k8s_cluster" {
  source = "../../../modules/kind/nginx_ingress/"

  cluster_name          = var.cluster_name
  kubernetes_local_path = pathexpand(var.kubernetes_local_path)

  # service_type = "LoadBalancer"
  service_type = "NodePort"

  add_ports = [{
    app_protocol = "http"
    name         = "http-default"
    port         = 80
    protocol     = "TCP"
    target_port  = "http"
    },
    {
      app_protocol = "https"
      name         = "https-dafault"
      port         = 443
      protocol     = "TCP"
      target_port  = "https"
  }]

  providers = {
    kubernetes = kubernetes
  }
}
