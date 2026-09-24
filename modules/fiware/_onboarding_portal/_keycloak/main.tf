locals {
  url_keycloak = "${var.keycloak.configuration.hostname}.${var.domain_name}"
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }
}

resource "random_password" "keycloak_password" {
  length           = 20
  special          = true
  override_special = "!#$*()-_=+[]{}<>:"
}

resource "kubernetes_secret" "keycloak_credentials" {
  metadata {
    name      = local.secrets_names.keycloak
    namespace = var.namespace
  }

  data = {
    "login-client-id"     = "onboarding-client"
    "login-client-secret" = random_password.keycloak_password.result
  }

  type = "Opaque"
}

resource "random_password" "issuance_password" {
  length           = 20
  special          = true
  override_special = "!#$*()-_=+[]{}<>:"
}

resource "kubernetes_secret" "issuance_secret" {
  metadata {
    name      = local.secrets_names.issuance
    namespace = var.namespace
  }

  data = {
    "store-pass"                                   = var.project_name
    "${var.keycloak.configuration.admin_username}" = var.keycloak_pass != null ? var.keycloak_pass : random_password.issuance_password.result
  }

  type = "Opaque"
}

resource "kubernetes_config_map" "provider_realm" {
  metadata {
    name      = "provider-realm"
    namespace = var.namespace
  }
  data = {
    "onboarding-realm.json" = templatefile("./keycloak-realm-onboarding.json", {
      onboarding_client_password = random_password.keycloak_password.result,
      onboarding_host            = local.onboarding_domain,
    })
  }
}

resource "helm_release" "keycloak" {
  depends_on = [
    kubernetes_namespace.namespace,
    kubernetes_secret.database_credentials,
    kubernetes_secret.issuance_secret,
    kubernetes_config_map.provider_realm
  ]

  version    = var.keycloak.version
  chart      = var.keycloak.chart_name
  repository = var.keycloak.repository
  name       = "keycloak"
  namespace  = var.namespace

  values = [
    templatefile("${path.module}/resources/helm_values/keycloak.yaml", {
      keycloak_config = var.keycloak.configuration,
      secrets_names   = local.secrets_names,
      keycloak_host   = local.url_keycloak,
      postgres_config = local.postgres_config
    })
  ]
}
