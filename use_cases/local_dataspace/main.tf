module "trust_anchor" {
  source = "../../modules/fiware/trust_anchor"

  namespace          = var.trust_anchor_namespace
  tailscale_hostname = var.trust_anchor_tailscale_hostname
}

# module "onboarding_portal" {
#   source = "../../modules/fiware/onboarding_portal"

#   namespace                = var.namespace
#   tailscale_enabled        = true
#   tailscale_hostname       = var.onboarding_tailscale_hostname
#   keycloak_public_url      = var.keycloak_public_url
#   onboarding_public_url    = var.onboarding_public_url
#   keycloak_realm           = var.keycloak_realm
#   keycloak_admin_password  = var.keycloak_admin_password
#   onboarding_client_secret = var.onboarding_client_secret
#   keycloak_store_password  = var.keycloak_store_password
#   persistence_enabled      = true

#   config = {
#     app = {
#       browserTitle      = "CitCom.ai - Onboarding Data Space"
#       enableThemeToggle = false
#       projectWebsiteUrl = "https://citcomtef.eu/"
#       marketplaceUrl    = "https://marketplace.example.com/"
#       documentToSignUrl = var.document_to_sign_url
#       login = {
#         openIdUrl    = "${var.keycloak_public_url}/realms/${var.keycloak_realm}"
#         clientId     = "$${APP_CLIENT_ID}"
#         clientSecret = "$${APP_CLIENT_SECRET}"
#       }
#       keycloak = {
#         baseUrl = "http://keycloak.${var.namespace}.svc.cluster.local:8080"
#         auth = {
#           clientId  = "admin-cli"
#           grantType = "password"
#           realmName = "master"
#           username  = "$${APP_KEYCLOAK_USERNAME}"
#           password  = "$${APP_KEYCLOAK_PASSWORD}"
#         }
#       }
#       tir = {
#         url = "http://tir.${var.trust_anchor_namespace}.svc.cluster.local:8080"
#       }
#     }
#     email = {
#       enabled = false
#       config  = {}
#       from    = "noreply@test.com"
#     }
#     database = {
#       host     = "postgres.${var.namespace}.svc.cluster.local"
#       database = "onboarding"
#       type     = "postgres"
#       port     = 5432
#     }
#   }

#   secrets = {
#     database = {
#       secretName  = "postgres.postgres.credentials.postgresql.acid.zalan.do"
#       usernameKey = "username"
#       passwordKey = "password"
#     }
#     login = {
#       secretName      = "onboarding-client-credentials"
#       clientIdKey     = "login-client-id"
#       clientSecretKey = "login-client-secret"
#     }
#     keycloak = {
#       secretName  = "issuance-secret"
#       usernameKey = "username"
#       passwordKey = "keycloak-admin"
#     }
#   }

#   depends_on = [module.trust_anchor]
# }
