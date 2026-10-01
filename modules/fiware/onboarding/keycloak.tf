# Keycloak and did-helper from the FIWARE Data Space Connector chart, with every other
# component of the connector disabled.

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
    enabled          = true
    fullnameOverride = "keycloak"

    keycloak = {
      adminUser      = var.keycloak_admin_username
      existingSecret = local.keycloak_admin_secret
      secretKeys = {
        adminPasswordKey = "password"
      }
      # Public URL: issuer of the tokens and base of every browser redirect.
      # TLS terminates at the Tailscale proxy.
      hostname     = local.keycloak_url
      proxyHeaders = "xforwarded"
      # The connector's own realm import is disabled (keycloak.realm below), so the
      # import of the mounted onboarding realm is requested explicitly
      extraArgs = ["--import-realm"]
    }

    # The connector ships a sample realm (test-realm); the onboarding one is mounted instead
    realm = {
      import = false
    }

    database = {
      host     = var.keycloak_database.host
      port     = tostring(var.keycloak_database.port)
      name     = var.keycloak_database.name
      username = "keycloak"
      # Both username and password are read from the Secret
      existingSecret = var.keycloak_database.secret_name
      secretKeys = {
        usernameKey = var.keycloak_database.username_key
        passwordKey = var.keycloak_database.password_key
      }
    }

    metrics = {
      enabled = false
    }

    extraVolumes = [
      {
        name = "realms"
        configMap = {
          name = kubernetes_config_map.realm.metadata[0].name
        }
      },
    ]
    extraVolumeMounts = [
      {
        name      = "realms"
        mountPath = "/opt/keycloak/data/import"
      },
    ]

    extraEnvVars = [
      {
        name  = "KC_HEAP_SIZE"
        value = "1024m"
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
  }

  # did-helper in Keycloak mode: serves https://<did_hostname>.<tailnet>/<realm>/did.json,
  # the DID document of every realm built on the fly from its JWKS (see did_helper.tf)
  did_helper_values = {
    fullnameOverride = "did-helper"
    config = {
      server = {
        runServer  = "true"
        serverPort = tostring(local.did_helper_port)
        didType    = "keycloak"
        # In-cluster URL: the JWKS of a realm does not depend on the public hostname
        keycloakHost = "http://keycloak.${var.namespace}.svc.cluster.local:${local.keycloak_service_port}"
        # Empty, or did-helper writes a file and exits instead of serving
        outputFile   = ""
        outputFormat = "json"
      }
      # The keys come from Keycloak, nothing to generate
      generateKey = {
        enabled = false
      }
    }
  }

  dsc_values = {
    # The admin password comes from Vault (keycloak-admin Secret)
    issuance = {
      generatePasswords = {
        enabled = false
      }
    }

    keycloak = local.keycloak_values
    did      = merge(local.did_helper_values, { enabled = var.did_creation_enabled })

    # Components of the connector enabled by default
    decentralizedIam      = { enabled = false }
    scorpio               = { enabled = false }
    "tm-forum-api"        = { enabled = false }
    "contract-management" = { enabled = false }
    "fdsc-edc"            = { enabled = false }
  }
}

resource "helm_release" "keycloak" {
  name      = "onboarding-dsc"
  namespace = var.namespace

  repository = var.dsc_chart.repository
  chart      = var.dsc_chart.name
  version    = var.dsc_chart.version

  values = [yamlencode(local.dsc_values)]

  wait    = true
  timeout = 900

  depends_on = [module.credentials]
}
