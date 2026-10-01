# did-helper (https://github.com/SEAMWARE/did-helper) in Keycloak mode, deployed by the
# Data Space Connector chart (keycloak.tf): resolves the did:web DIDs the portal
# generates for the realms it provisions.
#
#   did:web:<did_hostname>.<tailnet>:<realm>
#     -> https://<did_hostname>.<tailnet>/<realm>/did.json
#     -> DID document built on the fly from the JWKS of that Keycloak realm
#
# The DID in the document comes from the Host header of the request, so it matches the
# requested DID. Only deployed when the portal generates DIDs.

locals {
  did_helper_port         = 8080 # container port
  did_helper_service_port = 80   # Service port of the did-helper chart
}

# did:web requires HTTPS on the DID host. See ingress.tf for the Tailscale conventions.
resource "kubernetes_ingress_v1" "did_helper" {
  count = var.did_creation_enabled ? 1 : 0

  metadata {
    name        = "did-helper"
    namespace   = var.namespace
    annotations = var.ingress_annotations
  }

  spec {
    ingress_class_name = var.ingress_class_name

    tls {
      hosts = [var.did_hostname]
    }

    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "did-helper"
              port {
                number = local.did_helper_service_port
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.keycloak]
}
