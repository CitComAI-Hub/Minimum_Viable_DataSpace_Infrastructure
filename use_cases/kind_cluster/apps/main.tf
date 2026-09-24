module "traefik" {
  source = "../../../modules/traefik"
}

module "tailscale" {
  count  = var.enable_tailscale && var.tailscale_oauth_client_id != "" ? 1 : 0
  source = "../../../modules/tailscale"

  oauth_client_id     = var.tailscale_oauth_client_id
  oauth_client_secret = var.tailscale_oauth_client_secret
}

resource "kubernetes_ingress_v1" "traefik_tailscale" {
  count = var.enable_tailscale && var.tailscale_expose_traefik && var.tailscale_oauth_client_id != "" ? 1 : 0

  metadata {
    name      = "traefik-tailscale"
    namespace = module.traefik.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
    annotations = {
      "tailscale.com/tags" = "tag:k8s-operator"
    }
  }

  spec {
    ingress_class_name = "tailscale"

    tls {
      hosts = [var.tailscale_traefik_hostname]
    }

    rule {
      host = var.tailscale_traefik_hostname

      http {
        path {
          path_type = "Prefix"
          path      = "/"

          backend {
            service {
              name = "traefik"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    module.tailscale,
    module.traefik
  ]
}
