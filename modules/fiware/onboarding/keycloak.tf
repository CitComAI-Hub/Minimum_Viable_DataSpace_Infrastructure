# Realm imported on startup. The OIDC client secret stays as ${ONBOARDING_CLIENT_SECRET}:
# Keycloak replaces it with the environment variable, so it never goes through Terraform.
resource "kubernetes_config_map" "realm" {
  metadata {
    name      = "keycloak-realm"
    namespace = var.namespace
  }

  data = {
    "${var.realm}-realm.json" = templatefile("${path.module}/resources/keycloak-realm-onboarding.json", {
      onboarding_host            = local.onboarding_fqdn
      onboarding_client_password = "$${ONBOARDING_CLIENT_SECRET}"
    })
  }
}

locals {
  keycloak_values = {
    fullnameOverride = "keycloak"

    image = var.keycloak_image
    global = {
      security = {
        # Required by the Bitnami charts to use an image outside the bitnami repository
        allowInsecureImages = true
      }
    }

    auth = {
      adminUser         = var.keycloak_admin_username
      existingSecret    = local.keycloak_admin_secret
      passwordSecretKey = "password"
    }

    postgresql = {
      enabled = false
    }
    externalDatabase = {
      host                      = var.keycloak_database.host
      port                      = var.keycloak_database.port
      database                  = var.keycloak_database.name
      existingSecret            = var.keycloak_database.secret_name
      existingSecretUserKey     = var.keycloak_database.username_key
      existingSecretPasswordKey = var.keycloak_database.password_key
    }

    # TLS terminates at the Tailscale proxy; the chart Ingress is not used because it
    # sets a host on its rules, which a ProxyGroup ignores (see ingress.tf)
    ingress = {
      enabled = false
    }
    proxyHeaders     = "xforwarded"
    extraStartupArgs = "--import-realm"

    extraEnvVars = [
      {
        # Public URL: issuer of the tokens and base of every browser redirect
        name  = "KC_HOSTNAME"
        value = local.keycloak_url
      },
      {
        name  = "KC_FEATURES"
        value = "oid4vc-vci"
      },
      {
        name = "ONBOARDING_CLIENT_SECRET"
        valueFrom = {
          secretKeyRef = {
            name = local.onboarding_client_secret
            key  = "client-secret"
          }
        }
      },
    ]

    extraVolumes = [
      {
        name = "realm"
        configMap = {
          name = kubernetes_config_map.realm.metadata[0].name
        }
      },
    ]
    extraVolumeMounts = [
      {
        name      = "realm"
        mountPath = local.keycloak_import_directory
      },
    ]

    service = {
      ports = {
        http = local.keycloak_service_port
      }
    }

    resources = {
      requests = {
        cpu    = "500m"
        memory = "512Mi"
      }
      limits = {
        cpu    = "1"
        memory = "2Gi"
      }
    }
  }
}

resource "helm_release" "keycloak" {
  name      = "keycloak"
  namespace = var.namespace

  repository = var.keycloak_chart.repository
  chart      = var.keycloak_chart.name
  version    = var.keycloak_chart.version

  values = [yamlencode(local.keycloak_values)]

  wait    = true
  timeout = 900

  depends_on = [module.credentials]
}
