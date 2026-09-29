# Tailscale is the only entry point to the cluster: each service is exposed with
# its own Ingress of class "tailscale", served by a shared ProxyGroup, which makes
# it a Tailscale Service (https://<hostname>.<tailnet>.ts.net) with its own TLS certificate.
module "tailscale" {
  source = "../../../modules/tailscale"

  oauth_client_id             = var.tailscale_oauth_client_id
  oauth_client_secret         = var.tailscale_oauth_client_secret
  operator_hostname           = "${var.cluster_name}-ts-operator"
  proxy_group_hostname_prefix = "${var.cluster_name}-ingress"
  letsencrypt_staging         = var.tailscale_letsencrypt_staging
}

# Secrets platform: Vault (initialised, unsealed and configured automatically) and
# External Secrets Operator. Services declare their secrets with modules/vault/consumer.
module "vault" {
  source = "../../../modules/vault"

  ingress_class_name  = module.tailscale.ingress_class_name
  ingress_annotations = module.tailscale.ingress_annotations
  hostname            = var.vault_hostname

  # The operator must outlive the Vault Ingress on destroy, so it can remove its Tailscale Service
  depends_on = [module.tailscale]
}

# PostgreSQL: the CloudNativePG operator manages every instance in the cluster
module "postgres_operator" {
  source = "../../../modules/postgres/operator"
}

resource "kubernetes_namespace_v1" "databases" {
  metadata {
    name = "databases"
  }
}

# Shared instance for the configuration of the data space services: each one
# requests its own database and user with modules/postgres/database instead of
# deploying new instances. Data brokers get a separate instance.
module "dataspace_postgres" {
  source = "../../../modules/postgres"

  name      = "dataspace"
  namespace = kubernetes_namespace_v1.databases.metadata[0].name
  type      = "postgresql"

  vault_namespace = module.vault.namespace
  vault_address   = module.vault.internal_address

  # Vault must be unsealed and configured before the superuser credentials are
  # requested, and the operator must outlive the instance on destroy
  depends_on = [module.vault, module.postgres_operator]
}
