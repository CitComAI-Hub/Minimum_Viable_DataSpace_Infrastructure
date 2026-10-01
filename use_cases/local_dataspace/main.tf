resource "kubernetes_namespace" "trust_anchor" {
  metadata {
    name = var.trust_anchor_namespace
  }
}

# Database of the Trusted Issuers List in the shared PostgreSQL instance
# (deployed by kind_cluster/apps), with its password managed by Vault
module "trust_anchor_database" {
  source = "../../modules/postgres/database"

  name      = "til"
  namespace = kubernetes_namespace.trust_anchor.metadata[0].name
  database  = "tildb"
  username  = "til"
}

module "trust_anchor" {
  source = "../../modules/fiware/trust_anchor"

  namespace           = kubernetes_namespace.trust_anchor.metadata[0].name
  ingress_class_name  = var.ingress_class_name
  ingress_annotations = var.ingress_annotations
  tir_hostname        = var.trust_anchor_tir_hostname
  til_hostname        = var.trust_anchor_til_hostname

  database = {
    host         = module.trust_anchor_database.host
    port         = module.trust_anchor_database.port
    name         = module.trust_anchor_database.database
    username     = module.trust_anchor_database.username
    secret_name  = module.trust_anchor_database.secret_name
    password_key = module.trust_anchor_database.password_key
  }
}

# The Tailnet domain is published by modules/tailscale (kind_cluster/apps)
data "kubernetes_config_map" "tailnet" {
  metadata {
    name      = "tailnet"
    namespace = "tailscale"
  }
}

locals {
  tailnet_domain = coalesce(var.tailnet_domain, data.kubernetes_config_map.tailnet.data["domain"])
}

# Onboarding: Keycloak and the portal, each with its own database in the shared
# PostgreSQL instance. Approved participants are registered in the TIR.
resource "kubernetes_namespace" "onboarding" {
  metadata {
    name = var.onboarding_namespace
  }
}

module "keycloak_database" {
  source = "../../modules/postgres/database"

  name      = "onboarding-keycloak"
  namespace = kubernetes_namespace.onboarding.metadata[0].name
  database  = "keycloak"
}

module "onboarding_database" {
  source = "../../modules/postgres/database"

  name      = "onboarding-portal"
  namespace = kubernetes_namespace.onboarding.metadata[0].name
  database  = "onboarding"
}

module "onboarding" {
  source = "../../modules/fiware/onboarding"

  namespace           = kubernetes_namespace.onboarding.metadata[0].name
  tailnet_domain      = local.tailnet_domain
  keycloak_hostname   = var.keycloak_hostname
  onboarding_hostname = var.onboarding_hostname
  ingress_class_name  = var.ingress_class_name
  ingress_annotations = var.ingress_annotations
  egress_proxy_group  = var.egress_proxy_group

  keycloak_database = {
    host        = module.keycloak_database.host
    port        = module.keycloak_database.port
    name        = module.keycloak_database.database
    secret_name = module.keycloak_database.secret_name
  }
  onboarding_database = {
    host        = module.onboarding_database.host
    port        = module.onboarding_database.port
    name        = module.onboarding_database.database
    secret_name = module.onboarding_database.secret_name
  }

  tir_url                 = "http://${module.trust_anchor.tir_service}"
  agreement_document_path = coalesce(var.agreement_document_path, "${path.module}/../../modules/fiware/onboarding/resources/agreement.pdf")
}
