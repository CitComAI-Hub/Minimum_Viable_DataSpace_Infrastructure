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

      ingress = {
        enabled          = var.ingress_enabled
        ingressClassName = var.ingress_class_name
        annotations      = var.ingress_annotations
        # The Tailscale name comes from tls.hosts. The rule has no host: an Ingress
        # served by a ProxyGroup ignores rules whose host is not the full Tailnet FQDN
        hosts = [
          {
            host  = ""
            paths = [] # the chart defaults to "/"
          }
        ]
        tls = [
          {
            hosts = [var.hostname]
          }
        ]
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
