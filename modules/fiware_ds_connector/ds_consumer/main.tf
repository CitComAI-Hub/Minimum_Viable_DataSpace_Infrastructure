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
      ingress_class       = "traefik",
      til_operator_domain = "trusted-issuers-list.ds-operator.svc.cluster.local",
      did_provider_domain = "did-helper.provider-a.svc.cluster.local",
      # Generate a password for the database connection of trust-anchor.
      generate_passwords_enabled = true,
      iss_secret                 = "issuance-secret",
      # DID service
      did_enabled         = true,
      did_host_name       = var.services_names.did,
      did_port            = 3001,
      did_ingress_enabled = true,
      did_domain          = local.dns_dir[local.dns_domains.did],
      did_secret_tls      = local.secrets_tls[local.dns_domains.did],
      # PostgreSQL configuration
      postgresql_enabled               = true,
      postgresql_host_name             = var.services_names.postgresql,
      postgresql_user                  = "postgres",
      postgresql_keycloakdb_name       = "keycloak",
      postgresql_secret                = "postgresql-database-secret",
      postgresql_secrect_key_adminpass = "postgres-admin-password", # not editable
      postgresql_secrect_key_userpass  = "postgres-user-password",  # not editable
      # Keycloak configuration
      keycloak_enabled         = true,
      keycloak_host_name       = var.services_names.keycloak,
      keycloak_ingress_enabled = true,
      keycloak_domain          = local.dns_dir[local.dns_domains.keycloak],
      keycloak_secret_tls      = local.secrets_tls[local.dns_domains.keycloak],
      keycloak_user            = "keycloak-admin",
      keycloak_pass            = "keycloak-admin"
    })
  ]
}
