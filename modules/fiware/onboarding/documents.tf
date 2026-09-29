# Serves the agreement that applicants must sign under the portal hostname
# (/documents/agreement.pdf). The portal chart cannot mount extra files, so a small
# web server takes the /documents path of the portal Ingress.

locals {
  documents_labels = { app = "onboarding-documents" }
}

resource "kubernetes_config_map_v1" "documents" {
  count = local.documents_enabled ? 1 : 0

  metadata {
    name      = "onboarding-documents"
    namespace = var.namespace
  }

  binary_data = {
    "agreement.pdf" = filebase64(var.agreement_document_path)
  }
}

resource "kubernetes_deployment_v1" "documents" {
  count = local.documents_enabled ? 1 : 0

  metadata {
    name      = "onboarding-documents"
    namespace = var.namespace
    labels    = local.documents_labels
  }

  spec {
    replicas = 1

    selector {
      match_labels = local.documents_labels
    }

    template {
      metadata {
        labels = local.documents_labels
        annotations = {
          # restart when the document changes
          "checksum/documents" = sha256(kubernetes_config_map_v1.documents[0].binary_data["agreement.pdf"])
        }
      }

      spec {
        container {
          name  = "nginx"
          image = var.documents_image

          port {
            name           = "http"
            container_port = 8080
          }

          volume_mount {
            name       = "documents"
            mount_path = "/usr/share/nginx/html/documents"
            read_only  = true
          }

          readiness_probe {
            http_get {
              path = "/documents/agreement.pdf"
              port = "http"
            }
          }

          resources {
            requests = {
              cpu    = "10m"
              memory = "16Mi"
            }
            limits = {
              memory = "64Mi"
            }
          }
        }

        volume {
          name = "documents"
          config_map {
            name = kubernetes_config_map_v1.documents[0].metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "documents" {
  count = local.documents_enabled ? 1 : 0

  metadata {
    name      = "onboarding-documents"
    namespace = var.namespace
  }

  spec {
    selector = local.documents_labels

    port {
      name        = "http"
      port        = local.documents_service_port
      target_port = "http"
    }
  }
}
