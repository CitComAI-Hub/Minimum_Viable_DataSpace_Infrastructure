# Own Ingresses instead of the chart ones: with the "tailscale" class the Tailnet name
# comes from tls.hosts, and the rules have no host because an Ingress served by a
# ProxyGroup ignores rules whose host is not the full Tailnet FQDN.

resource "kubernetes_ingress_v1" "keycloak" {
  metadata {
    name        = "keycloak"
    namespace   = var.namespace
    annotations = var.ingress_annotations
  }

  # Wait until the Tailscale Service serves Keycloak: the egress for the portal must be
  # created after it (see main.tf). Its address only appears once the certificate is
  # issued, so a Let's Encrypt rate limit on this hostname makes the apply time out.
  wait_for_load_balancer = true

  spec {
    ingress_class_name = var.ingress_class_name

    tls {
      hosts = [var.keycloak_hostname]
    }

    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "keycloak"
              port {
                number = local.keycloak_service_port
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.keycloak]
}

resource "kubernetes_ingress_v1" "onboarding" {
  metadata {
    name        = "onboarding"
    namespace   = var.namespace
    annotations = var.ingress_annotations
  }

  spec {
    ingress_class_name = var.ingress_class_name

    tls {
      hosts = [var.onboarding_hostname]
    }

    rule {
      http {
        dynamic "path" {
          for_each = local.documents_enabled ? [1] : []
          content {
            path      = "/documents"
            path_type = "Prefix"

            backend {
              service {
                name = kubernetes_service.documents[0].metadata[0].name
                port {
                  number = local.documents_service_port
                }
              }
            }
          }
        }

        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "onboarding"
              port {
                number = local.onboarding_service_port
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.onboarding]
}
