resource "kubernetes_namespace" "onboarding" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "postgres" {
  depends_on = [kubernetes_namespace.onboarding]

  metadata {
    name      = "onboarding-postgres-credentials"
    namespace = var.namespace
  }

  data = {
    username = "postgres"
    password = var.postgres_password
  }

  type = "Opaque"
}

resource "kubernetes_config_map" "postgres_init" {
  depends_on = [kubernetes_namespace.onboarding]

  metadata {
    name      = "onboarding-postgres-init"
    namespace = var.namespace
  }

  data = {
    "001-create-databases.sql" = <<-SQL
      SELECT 'CREATE DATABASE onboarding'
      WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'onboarding')\gexec
    SQL
  }
}

resource "kubernetes_persistent_volume_claim" "postgres" {
  depends_on = [kubernetes_namespace.onboarding]

  metadata {
    name      = "onboarding-postgres"
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = var.postgres_storage_size
      }
    }
  }
}

resource "kubernetes_deployment" "postgres" {
  depends_on = [
    kubernetes_secret.postgres,
    kubernetes_config_map.postgres_init,
    kubernetes_persistent_volume_claim.postgres
  ]

  metadata {
    name      = "postgres"
    namespace = var.namespace
    labels = {
      app = "postgres"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "postgres"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }

      spec {
        container {
          name  = "postgres"
          image = "postgres:15-alpine"

          port {
            container_port = 5432
          }

          env {
            name  = "POSTGRES_USER"
            value = "postgres"
          }
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres.metadata[0].name
                key  = "password"
              }
            }
          }
          env {
            name  = "POSTGRES_DB"
            value = "keycloakdb"
          }

          volume_mount {
            name       = "postgres-data"
            mount_path = "/var/lib/postgresql/data"
          }
          volume_mount {
            name       = "postgres-init"
            mount_path = "/docker-entrypoint-initdb.d"
          }
        }

        volume {
          name = "postgres-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.postgres.metadata[0].name
          }
        }
        volume {
          name = "postgres-init"
          config_map {
            name = kubernetes_config_map.postgres_init.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  depends_on = [kubernetes_deployment.postgres]

  metadata {
    name      = "postgres"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "postgres"
    }

    port {
      port        = 5432
      target_port = 5432
    }
  }
}

resource "kubernetes_secret" "issuance" {
  depends_on = [kubernetes_namespace.onboarding]

  metadata {
    name      = "issuance-secret"
    namespace = var.namespace
  }

  data = {
    "keycloak-admin" = var.keycloak_admin_password
    "store-pass"     = var.keycloak_store_password
    username         = "keycloak-admin"
  }

  type = "Opaque"
}

resource "kubernetes_secret" "onboarding_client" {
  depends_on = [kubernetes_namespace.onboarding]

  metadata {
    name      = "onboarding-client-credentials"
    namespace = var.namespace
  }

  data = {
    "login-client-id"     = "onboarding-client"
    "login-client-secret" = var.onboarding_client_secret
  }

  type = "Opaque"
}

resource "kubernetes_config_map" "provider_realm" {
  depends_on = [kubernetes_namespace.onboarding]

  metadata {
    name      = "provider-realm"
    namespace = var.namespace
  }

  data = {
    "onboarding-realm.json" = templatefile("${path.module}/keycloak-realm-onboarding.json", {
      onboarding_client_password = var.onboarding_client_secret
      onboarding_host            = trimsuffix(trimprefix(var.onboarding_public_url, "https://"), "/")
    })
  }
}

resource "helm_release" "keycloak" {
  name             = var.keycloak_release_name
  repository       = var.keycloak_chart.repository
  chart            = var.keycloak_chart.name
  version          = var.keycloak_chart.version
  namespace        = var.namespace
  create_namespace = true

  wait    = true
  timeout = 900

  values = concat([yamlencode(local.keycloak_chart_values)], var.keycloak_extra_values)

  depends_on = [
    kubernetes_namespace.onboarding,
    kubernetes_service.postgres,
    kubernetes_secret.issuance,
    kubernetes_config_map.provider_realm
  ]
}

resource "helm_release" "onboarding_portal" {
  name             = var.release_name
  repository       = var.chart.repository
  chart            = var.chart.name
  version          = var.chart.version
  namespace        = var.namespace
  create_namespace = true

  wait    = true
  timeout = 600

  values = concat([yamlencode(local.onboarding_chart_values)], var.extra_values)

  depends_on = [
    helm_release.keycloak,
    kubernetes_secret.onboarding_client
  ]
}
