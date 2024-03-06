locals {
  ca_clusterissuer_name = "ca-certificates"
}

module "ca_configuration" {
  source = "../../modules/ca_configuration/"

  namespace          = "cert-manager"
  clusterissuer_name = local.ca_clusterissuer_name
  secret_ca_container = "ca-cert-manager"
}

module "waltid_didweb" {
  source     = "../../modules/waltid_ssikit/"
  depends_on = [module.ca_configuration]

  providers = {
    kubernetes = kubernetes
  }

  namespace             = "did-server"
  ca_clusterissuer_name = local.ca_clusterissuer_name
  nginx_volume_path     = "/etc/kubernetes/data/nginx"
  nginx_port = [
    {
      container_port = 80
    },
    {
      container_port = 443
    }
  ]
  nginx_volume_mount = [
    {
      name       = "nginx-conf"
      mount_path = "/etc/nginx/conf.d/"
    },
    {
      name       = "nginx-ssl-certs"
      mount_path = "/etc/nginx/ssl"
    },
    {
      name       = "nginx-web-data"
      mount_path = "/usr/share/nginx/html"
    }
  ]
}
