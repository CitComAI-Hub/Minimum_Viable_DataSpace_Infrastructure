# Administrator of the onboarding portal. The portal authenticates against the
# onboarding realm, which the imported JSON ships without users, so this Job creates
# the user (or resets it) with the password generated in Vault, through the Keycloak
# admin API. It also works on an existing realm, which Keycloak never re-imports.
resource "kubernetes_job" "portal_admin" {
  metadata {
    name      = "onboarding-portal-admin"
    namespace = var.namespace
  }

  wait_for_completion = true

  timeouts {
    create = "10m"
    update = "10m"
  }

  spec {
    backoff_limit = 6

    template {
      metadata {
        labels = { app = "onboarding-portal-admin" }
      }

      spec {
        restart_policy = "Never"

        security_context {
          run_as_non_root = true
          run_as_user     = 1000
        }

        container {
          name    = "configure"
          image   = var.portal_admin_image
          command = ["sh", "-c"]
          args = [<<-EOT
            set -eu
            until curl -sf -o /dev/null "$KC_URL/realms/$REALM"; do echo "waiting for Keycloak"; sleep 5; done

            TOKEN=$(curl -sf "$KC_URL/realms/master/protocol/openid-connect/token" \
              -d grant_type=password -d client_id=admin-cli \
              --data-urlencode "username=$KC_ADMIN_USERNAME" --data-urlencode "password=$KC_ADMIN_PASSWORD" \
              | jq -r .access_token)
            api() { curl -sf -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" "$@"; }
            USERS="$KC_URL/admin/realms/$REALM/users"

            # Complete profile and no required actions, so the first login goes straight in
            PROFILE=$(jq -n --arg u "$PORTAL_ADMIN_USERNAME" --arg e "$PORTAL_ADMIN_EMAIL" \
              '{username:$u, email:$e, emailVerified:true, firstName:"Portal", lastName:"Administrator", enabled:true, requiredActions:[]}')

            ID=$(api "$USERS?username=$PORTAL_ADMIN_USERNAME&exact=true" | jq -r '.[0].id // empty')
            if [ -z "$ID" ]; then
              api -X POST "$USERS" -d "$PROFILE"
              ID=$(api "$USERS?username=$PORTAL_ADMIN_USERNAME&exact=true" | jq -r '.[0].id')
              echo "User $PORTAL_ADMIN_USERNAME created in realm $REALM"
            else
              api -X PUT "$USERS/$ID" -d "$PROFILE"
              echo "User $PORTAL_ADMIN_USERNAME updated in realm $REALM"
            fi

            api -X PUT "$USERS/$ID/reset-password" \
              -d "$(jq -n --arg p "$PORTAL_ADMIN_PASSWORD" '{type:"password", value:$p, temporary:false}')"
            echo "Password of $PORTAL_ADMIN_USERNAME set from Vault"
          EOT
          ]

          env {
            name  = "HOME"
            value = "/tmp"
          }
          env {
            # In-cluster URL: the admin API does not need the public one
            name  = "KC_URL"
            value = "http://keycloak.${var.namespace}.svc.cluster.local:${local.keycloak_service_port}"
          }
          env {
            name  = "REALM"
            value = var.realm
          }
          env {
            name  = "PORTAL_ADMIN_EMAIL"
            value = "${var.portal_admin_username}@${local.onboarding_fqdn}"
          }
          env {
            name = "KC_ADMIN_USERNAME"
            value_from {
              secret_key_ref {
                name = local.keycloak_admin_secret
                key  = "username"
              }
            }
          }
          env {
            name = "KC_ADMIN_PASSWORD"
            value_from {
              secret_key_ref {
                name = local.keycloak_admin_secret
                key  = "password"
              }
            }
          }
          env {
            name = "PORTAL_ADMIN_USERNAME"
            value_from {
              secret_key_ref {
                name = local.portal_admin_secret
                key  = "username"
              }
            }
          }
          env {
            name = "PORTAL_ADMIN_PASSWORD"
            value_from {
              secret_key_ref {
                name = local.portal_admin_secret
                key  = "password"
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.keycloak, module.credentials]
}
