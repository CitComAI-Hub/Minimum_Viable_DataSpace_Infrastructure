# Automatic Vault bootstrap: init + unseal + configuration, with no manual steps.
# Runs as a Deployment inside the cluster, so Terraform never needs to reach Vault
# nor hold a Vault token, and generated secret values never end up in the state.
# It also reconciles the consumers registered by the consumer submodule.

locals {
  vault_ns = helm_release.vault.namespace # referencing it creates the dependency on the helm_release
}

resource "kubernetes_service_account" "bootstrap" {
  metadata {
    name      = "vault-bootstrap"
    namespace = local.vault_ns
  }
}

resource "kubernetes_role" "bootstrap" {
  metadata {
    name      = "vault-bootstrap"
    namespace = local.vault_ns
  }

  # Create the vault-init secret (where the init keys are stored)...
  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["create"]
  }

  # ...and only manage that one afterwards
  rule {
    api_groups     = [""]
    resources      = ["secrets"]
    resource_names = ["vault-init"]
    verbs          = ["get", "patch", "update"]
  }

  # Read the consumer registrations
  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_role_binding" "bootstrap" {
  metadata {
    name      = "vault-bootstrap"
    namespace = local.vault_ns
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.bootstrap.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.bootstrap.metadata[0].name
    namespace = local.vault_ns
  }
}

resource "kubernetes_config_map" "bootstrap" {
  metadata {
    name      = "vault-bootstrap"
    namespace = local.vault_ns
  }

  data = {
    "bootstrap.sh" = file("${path.module}/bootstrap.sh")
  }
}

resource "kubernetes_deployment" "bootstrap" {
  metadata {
    name      = "vault-bootstrap"
    namespace = local.vault_ns
    labels    = { app = "vault-bootstrap" }
  }

  # Terraform waits for the rollout, i.e. until Vault is initialised, unsealed and configured
  wait_for_rollout = true

  spec {
    replicas = 1

    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = { app = "vault-bootstrap" }
    }

    template {
      metadata {
        labels = { app = "vault-bootstrap" }
        annotations = {
          # restart the pod when the script changes
          "checksum/script" = sha256(kubernetes_config_map.bootstrap.data["bootstrap.sh"])
        }
      }

      spec {
        service_account_name = kubernetes_service_account.bootstrap.metadata[0].name

        security_context {
          run_as_non_root = true
          run_as_user     = 1000
        }

        container {
          name    = "bootstrap"
          image   = var.bootstrap_image
          command = ["sh", "/bootstrap/bootstrap.sh"]

          env {
            name  = "VAULT_ADDR"
            value = "http://vault.${local.vault_ns}.svc.cluster.local:8200"
          }
          env {
            name  = "NAMESPACE"
            value = local.vault_ns
          }
          env {
            name  = "CONSUMER_LABEL"
            value = "${local.consumer_label_key}=${local.consumer_label_value}"
          }
          env {
            name  = "HOME"
            value = "/tmp"
          }

          # Ready only while Vault is unsealed and configured
          readiness_probe {
            exec {
              command = ["test", "-f", "/tmp/ready"]
            }
            period_seconds = 5
          }

          volume_mount {
            name       = "bootstrap"
            mount_path = "/bootstrap"
            read_only  = true
          }

          resources {
            requests = {
              cpu    = "10m"
              memory = "32Mi"
            }
            limits = {
              memory = "128Mi"
            }
          }
        }

        volume {
          name = "bootstrap"
          config_map {
            name = kubernetes_config_map.bootstrap.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [kubernetes_role_binding.bootstrap]
}
