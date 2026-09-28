locals {
  chart_values = {
    postgres-operator = {
      enabled = var.postgres_operator_enabled
    }
    managedPostgres = {
      enabled = var.managed_postgres_enabled
    }
    trusted-issuers-list = {
      enabled          = true
      fullnameOverride = "tir"
      service = {
        port = 8080
      }
      database = {
        persistence = true
        host        = "postgres"
        port        = 5432
        name        = "tildb"
        username    = "til"
      }
      ingress = {
        tir = {
          enabled   = var.tailscale_enabled
          className = "tailscale"
          annotations = {
            "tailscale.com/tags" = "tag:k8s-operator"
          }
          hosts = [
            {
              host = var.tailscale_hostname
              paths = [
                {
                  path     = "/"
                  pathType = "Prefix"
                }
              ]
            }
          ]
          tls = [
            {
              hosts = [var.tailscale_hostname]
            }
          ]
        }
      }
    }
  }
}
