# Declares the secrets a service needs and syncs them into its namespace:
#   - a ConfigMap in the Vault namespace that registers the consumer; the Vault
#     bootstrap picks it up and creates the policy, the role and the secret values
#   - a ServiceAccount (eso-<name>), bound to the Vault role eso-<name>
#   - a "vault-<name>" SecretStore that authenticates with that ServiceAccount
#   - one ExternalSecret per Kubernetes Secret

locals {
  # Must match the label watched by the bootstrap in modules/vault
  consumer_label_key   = "vault.mvds/consumer"
  consumer_label_value = "true"

  eso_api_version = "external-secrets.io/v1"
  store_name      = "vault-${var.name}"
}

resource "kubernetes_service_account_v1" "this" {
  metadata {
    name      = "eso-${var.name}"
    namespace = var.namespace
  }
}

resource "kubernetes_config_map_v1" "registration" {
  metadata {
    name      = "consumer-${var.name}"
    namespace = var.vault_namespace
    labels = {
      (local.consumer_label_key) = local.consumer_label_value
    }
  }

  data = {
    "consumer.json" = jsonencode({
      name            = var.name
      namespace       = var.namespace
      service_account = kubernetes_service_account_v1.this.metadata[0].name
      secrets         = values(var.secrets)
    })
  }
}

resource "kubectl_manifest" "secret_store" {
  yaml_body = yamlencode({
    apiVersion = local.eso_api_version
    kind       = "SecretStore"
    metadata = {
      name      = local.store_name
      namespace = var.namespace
    }
    spec = {
      provider = {
        vault = {
          server  = var.vault_address
          path    = "secret"
          version = "v2"
          auth = {
            kubernetes = {
              mountPath = "kubernetes"
              role      = "eso-${var.name}"
              serviceAccountRef = {
                name = kubernetes_service_account_v1.this.metadata[0].name
              }
            }
          }
        }
      }
    }
  })

  depends_on = [kubernetes_config_map_v1.registration]
}

resource "kubectl_manifest" "external_secret" {
  for_each = var.secrets

  yaml_body = yamlencode({
    apiVersion = local.eso_api_version
    kind       = "ExternalSecret"
    metadata = {
      name      = each.key
      namespace = var.namespace
    }
    spec = {
      refreshInterval = var.refresh_interval
      secretStoreRef = {
        name = local.store_name
        kind = "SecretStore"
      }
      target = {
        name           = each.key
        creationPolicy = "Owner"
        template = {
          type = each.value.type
        }
      }
      data = [
        for k in concat(keys(each.value.static), each.value.generated_fields) : {
          secretKey = k
          remoteRef = {
            key      = each.value.vault_path
            property = k
          }
        }
      ]
    }
  })

  dynamic "wait_for" {
    for_each = var.wait_for_secrets ? [1] : []
    content {
      condition {
        type   = "Ready"
        status = "True"
      }
    }
  }

  depends_on = [kubectl_manifest.secret_store]
}
