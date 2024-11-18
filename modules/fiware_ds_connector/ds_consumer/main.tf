resource "helm_release" "ds_consumer" {
  version          = var.connector.version
  chart            = var.connector.chart_name
  repository       = var.connector.repository
  name             = var.services_names.connector
  namespace        = var.namespace
  create_namespace = true
  wait             = true

  values = [
    templatefile("${local.helm_conf_yaml_path}/connector.yaml", {
      ingress_class    = var.ingress_class,
      ingress_enabled  = var.enable_ingress,
      services_enabled = var.enable_services,
      #
      til_operator_domain = "trusted-issuers-list.${var.operator_namespace}.svc.cluster.local",
      til_provider_domain = "trusted-issuers-list.${var.provider_namespace}.svc.cluster.local",
      did_provider_domain = "did-helper.${var.provider_namespace}.svc.cluster.local",
      # Generate a password for the database connection of trust-anchor.
      iss_secret = "issuance-secret",
      # Keycloak configuration
      keycloak_host_name  = var.services_names.keycloak,
      keycloak_config     = var.keycloak,
      keycloak_domain     = local.dns_dir[local.dns_domains.keycloak],
      keycloak_secret_tls = local.secrets_tls[local.dns_domains.keycloak],
      # DID service
      did_host_name  = var.services_names.did,
      did_config     = var.did,
      did_domain     = local.dns_dir[local.dns_domains.did],
      did_secret_tls = local.secrets_tls[local.dns_domains.did],
      # PostgreSQL configuration
      postgresql_host_name             = var.services_names.postgresql,
      postgresql_config                = var.postgresql,
      postgresql_secrect_key_adminpass = "postgres-admin-password", # not editable
      postgresql_secrect_key_userpass  = "postgres-user-password",  # not editable
    })
  ]
}
