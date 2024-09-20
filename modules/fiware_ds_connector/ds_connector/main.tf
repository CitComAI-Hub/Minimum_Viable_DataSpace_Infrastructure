resource "helm_release" "ds_connector" {
  version          = var.connector.version
  chart            = var.connector.chart_name
  repository       = var.connector.repository
  name             = var.services_names.connector
  namespace        = var.namespace
  create_namespace = true
  wait             = true

  values = [
    templatefile("${local.helm_conf_yaml_path}/connector.yaml", {
      # Generate a password for the database connection of trust-anchor.
      generate_passwords_enabled = true,
      # MySQL configuration
      mysql_enabled    = true,
      mysql_host_name  = var.services_names.mysql,
      mysql_secret     = "mysql-database-secret",
      mysql_tildb_name = "tildb",
      mysql_ccsdb_name = "ccsdb",
      # Trusted Issuers List
      til_enabled   = false,
      til_host_name = var.services_names.til,
      # Credentials Configuration Service
      ccs_enabled   = false,
      ccs_host_name = var.services_names.ccs,
      # PostgreSQL configuration
      postgresql_enabled               = true,
      postgresql_host_name             = var.services_names.postgresql,
      postgresql_secret                = "postgresql-database-secret",
      postgresql_secrect_key_adminpass = "postgresql-database-admin-pass",
      postgresql_secrect_key_userpass  = "postgresql-database-user-pass",
      # Postgis
      postgis_enabled = true,
    })
  ]
}
