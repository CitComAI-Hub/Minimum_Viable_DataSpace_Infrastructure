locals {
  keycloak_chart_values = {
    issuance = {
      generatePasswords = {
        enabled    = false
        secretName = "issuance-secret"
      }
    }
    decentralizedIam = { enabled = false }
    vcAuthentication = {
      managedPostgres = {
        enabled = false
        config = {
          users = {
            postgres   = ["superuser", "createdb"]
            keycloak   = ["createdb"]
            onboarding = ["createdb"]
          }
          databases = {
            keycloakdb = "keycloak"
            onboarding = "onboarding"
          }
        }
      }
    }
    keycloak = {
      enabled          = true
      fullnameOverride = "keycloak"
      postgres         = { enabled = false }
      metrics          = { enabled = false }
      realm = {
        import      = true
        name        = var.keycloak_realm
        frontendURL = var.keycloak_public_url
      }
      extraVolumeMounts = [{
        name      = "realms"
        mountPath = "/opt/keycloak/data/import"
      }]
      extraVolumes = [{
        name = "realms"
        configMap = {
          name = "provider-realm"
        }
      }]
      keycloak = {
        adminUser      = "keycloak-admin"
        existingSecret = "issuance-secret"
        secretKeys = {
          adminPasswordKey = "keycloak-admin"
        }
        proxyHeaders = "xforwarded"
      }
      extraEnvVars = [
        {
          name = "STORE_PASS"
          valueFrom = {
            secretKeyRef = {
              name = "issuance-secret"
              key  = "store-pass"
            }
          }
        },
        {
          name = "KC_ADMIN_PASSWORD"
          valueFrom = {
            secretKeyRef = {
              name = "issuance-secret"
              key  = "keycloak-admin"
            }
          }
        },
        {
          name  = "KC_HEAP_SIZE"
          value = "1024m"
        }
      ]
      extraInitContainers = [{
        name            = "create-keycloak-db"
        image           = "postgres:15-alpine"
        imagePullPolicy = "IfNotPresent"
        command         = ["/bin/sh", "-c"]
        args = [<<-EOT
          set -eu
          export PGPASSWORD="$DB_PASSWORD"
          until pg_isready -h "$DB_HOST" -U "$DB_USER"; do sleep 2; done
          exists=$(psql -h "$DB_HOST" -U "$DB_USER" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$TARGET_DB'")
          if [ "$exists" != "1" ]; then
            psql -h "$DB_HOST" -U "$DB_USER" -d postgres -c "CREATE DATABASE \"$TARGET_DB\""
          fi
        EOT
        ]
        env = [
          {
            name  = "DB_HOST"
            value = "postgres"
          },
          {
            name  = "DB_USER"
            value = "postgres"
          },
          {
            name = "DB_PASSWORD"
            valueFrom = {
              secretKeyRef = {
                name = "onboarding-postgres-credentials"
                key  = "password"
              }
            }
          },
          {
            name  = "TARGET_DB"
            value = "keycloakdb"
          }
        ]
      }]
      resources = {
        requests = {
          cpu    = "500m"
          memory = "500Mi"
        }
        limits = {
          cpu    = "1"
          memory = "2Gi"
        }
      }
      ingress = {
        enabled   = true
        className = "tailscale"
        annotations = {
          "tailscale.com/tags" = "tag:k8s-operator"
        }
        hosts = [{
          host = var.keycloak_tailscale_hostname
          paths = [{
            path     = "/"
            pathType = "Prefix"
          }]
        }]
        tls = [{
          secretName = "keycloak-tls"
          hosts      = [var.keycloak_tailscale_hostname]
        }]
      }
      database = {
        host           = "postgres"
        name           = "keycloakdb"
        username       = "postgres"
        existingSecret = "onboarding-postgres-credentials"
        secretKeys = {
          usernameKey = "username"
          passwordKey = "password"
        }
      }
    }
    trusted-issuers-list         = { enabled = false }
    vcverifier                   = { enabled = false }
    "credentials-config-service" = { enabled = false }
    dss                          = { enabled = false }
    odrlAuthorization            = { "odrl-pap" = { enabled = false } }
    scorpio                      = { enabled = false }
    "tm-forum-api"               = { enabled = false }
    "contract-management"        = { enabled = false }
    marketplace                  = { enabled = false }
    "fdsc-edc"                   = { enabled = false }
    vault                        = { enabled = false }
    did                          = { enabled = false }
    "vc-operator"                = { enabled = false }
    "fdsc-dashboard"             = { enabled = false }
    prometheus                   = { enabled = false }
    grafana                      = { enabled = false }
    "cert-manager"               = { enabled = false }
    "mongo-operator"             = { enabled = false }
    managedMongo                 = { enabled = false }
    "opentelemetry-operator"     = { enabled = false }
    "opentelemetry-collector"    = { enabled = false }
    tempo                        = { enabled = false }
  }

  onboarding_chart_values = {
    replicaCount     = var.replicas
    fullnameOverride = var.name
    service = {
      type = "ClusterIP"
      port = var.service_port
    }
    ingress = {
      enabled     = var.tailscale_enabled
      className   = "tailscale"
      annotations = { "tailscale.com/tags" = "tag:k8s-operator" }
      hosts = [{
        host = var.tailscale_hostname
        paths = [{
          path     = "/"
          pathType = "Prefix"
        }]
      }]
      tls = [{
        secretName = "onboarding-tls"
        hosts      = [var.tailscale_hostname]
      }]
    }
    config       = var.config
    secrets      = var.secrets
    extraEnvVars = var.extra_env_vars
    persistence = {
      enabled      = var.persistence_enabled
      create       = var.persistence_enabled
      storageClass = var.storage_class_name
      size         = var.persistence_size
    }
  }
}

