locals {
  # Label of the ConfigMaps (created by the consumer submodule) that declare which
  # secrets each service needs. Must match modules/vault/consumer.
  consumer_label_key   = "vault.mvds/consumer"
  consumer_label_value = "true"

  vault_values = {
    global = {
      enabled = true
      # TLS terminates at the ingress; inside the cluster Vault listens on HTTP
      tlsDisable = true
    }

    # No injector: secrets are consumed through External Secrets Operator
    injector = {
      enabled = false
    }

    server = {
      standalone = {
        enabled = true # 1 replica, "file" storage (chart default config)
      }

      dataStorage = {
        enabled      = true
        size         = var.storage_size
        storageClass = var.storage_class
      }

      # Own Ingress below, so Terraform can wait for its Tailnet address
      ingress = {
        enabled = false
      }
    }

    ui = {
      enabled = true
    }
  }
}

resource "helm_release" "vault" {
  name             = "vault"
  namespace        = var.namespace
  create_namespace = true

  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = var.chart_version

  # The pod becomes Ready even while Vault is sealed (the chart readinessProbe allows it);
  # the bootstrap Deployment is what waits for Vault to be usable
  wait    = true
  timeout = 600

  values = [yamlencode(local.vault_values)]
}

# With the "tailscale" class the Tailnet name comes from tls.hosts, and the rule has no
# host because an Ingress served by a ProxyGroup ignores rules whose host is not the
# full Tailnet FQDN. The apply does not wait for its address: it only appears once the
# TLS certificate is issued, which Let's Encrypt rate limits may delay for days.
resource "kubernetes_ingress_v1" "vault" {
  count = var.ingress_enabled ? 1 : 0

  metadata {
    name        = "vault"
    namespace   = helm_release.vault.namespace
    annotations = var.ingress_annotations
  }

  spec {
    ingress_class_name = var.ingress_class_name

    tls {
      hosts = [var.hostname]
    }

    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "vault"
              port {
                number = 8200
              }
            }
          }
        }
      }
    }
  }
}
