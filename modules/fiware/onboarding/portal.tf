# The chart always writes storageClassName, and "" disables dynamic provisioning,
# so the cluster default StorageClass is looked up when none is given
data "kubernetes_resources" "storage_classes" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
}

locals {
  default_storage_class = one([
    for sc in data.kubernetes_resources.storage_classes.objects : sc.metadata.name
    if try(sc.metadata.annotations["storageclass.kubernetes.io/is-default-class"], "false") == "true"
  ])
  storage_class = var.storage_class != null ? var.storage_class : local.default_storage_class

  # Credentials are not in the values: the chart injects them from Secrets as the
  # environment variables (APP_*) that application.yaml references
  onboarding_values = {
    fullnameOverride = "onboarding"

    config = {
      app = {
        browserTitle      = var.app.browser_title
        enableThemeToggle = var.app.enable_theme_toggle
        projectWebsiteUrl = var.app.project_website_url
        marketplaceUrl    = var.app.marketplace_url
        documentToSignUrl = local.agreement_document_url
        login = {
          openIdUrl = "${local.keycloak_url}/realms/${var.realm}"
        }
        keycloak = {
          baseUrl            = local.keycloak_url
          didCreationEnabled = var.did_creation_enabled
        }
        tir = {
          url = var.tir_url
        }
      }
      database = {
        host     = var.onboarding_database.host
        port     = var.onboarding_database.port
        database = var.onboarding_database.name
      }
      email = {
        enabled = false
      }
      # Base of the generated DIDs: each provisioned realm gets <didWebHost>:<realm>
      didGenerator = {
        didWebHost = var.did_creation_enabled ? local.did_web_host : ""
      }
    }

    secrets = {
      database = {
        secretName  = var.onboarding_database.secret_name
        usernameKey = var.onboarding_database.username_key
        passwordKey = var.onboarding_database.password_key
      }
      login = {
        secretName      = local.onboarding_client_secret
        clientIdKey     = "client-id"
        clientSecretKey = "client-secret"
      }
      keycloak = {
        secretName  = local.keycloak_admin_secret
        usernameKey = "username"
        passwordKey = "password"
      }
    }

    persistence = {
      enabled      = true
      create       = true
      size         = var.persistence_size
      storageClass = local.storage_class
    }

    # See ingress.tf
    ingress = {
      enabled = false
    }
  }
}

resource "helm_release" "onboarding" {
  name      = "onboarding"
  namespace = var.namespace

  repository = var.onboarding_chart.repository
  chart      = var.onboarding_chart.name
  version    = var.onboarding_chart.version

  values = [yamlencode(local.onboarding_values)]

  wait    = true
  timeout = 600

  # Keycloak must be reachable at its public URL from the portal pod
  depends_on = [
    helm_release.keycloak,
    kubernetes_ingress_v1.keycloak,
    module.keycloak_egress,
  ]
}
