resource "helm_release" "connector" {
  chart            = var.connector.chart_name
  version          = var.connector.version
  repository       = var.connector.repository
  name             = var.services_names.connector
  namespace        = var.namespace
  create_namespace = true
  wait             = true

  values = [
    templatefile("${local.helm_conf_yaml_path}/connector.yaml", {
      did_domain = local.did_methods[var.did_option],
      # MongoDB
      mongodb_enable        = var.mongodb.enable_service,
      mongodb_name          = var.services_names.mongo,
      mongodb_auth_enable   = var.mongodb.auth_enabled,
      mongodb_root_password = var.mongodb.root_password,
      # MySQL
      mysql_enable        = var.mysql.enable_service,
      mysql_name          = var.services_names.mysql,
      mysql_root_password = var.mysql.root_password,
      mysql_password      = var.mysql.root_password,
      # Postgresql
      postgresql_enable        = var.postgresql.enable_service,
      postgresql_name          = var.services_names.postgresql,
      postgresql_root_password = var.postgresql.root_password,
      postgresql_user_name     = var.postgresql.user_name,
      postgresql_user_password = var.postgresql.user_password,
      postgresql_db_name       = var.postgresql.db_name,
      # Walt-ID
      waltid_enable     = var.walt_id.enable_service,
      waltid_name       = var.services_names.walt_id,
      waltid_ingress    = var.walt_id.enable_ingress,
      waltid_domain     = local.dns_dir[local.dns_domains.walt_id],
      waltid_secret_tls = local.secrets_tls[local.dns_domains.walt_id],
      # Orion-LD
      orionld_enable = var.orion_ld.enable_service,
      orionld_name   = var.services_names.orion_ld,
      # Credentials Config Service
      ccs_enable  = var.credentials_config_service.enable_service,
      ccs_name    = var.services_names.ccs,
      ccs_db_name = var.credentials_config_service.db_name,
      # Trusted Issuers List
      til_enable     = var.trusted_issuers_list.enable_service,
      til_name       = var.services_names.til,
      til_db_name    = var.trusted_issuers_list.db_name,
      til_domain     = local.dns_dir[local.dns_domains.til],
      til_secret_tls = local.secrets_tls[local.dns_domains.til],
      tir_domain     = local.dns_dir[local.dns_domains.tir],
      tir_secret_tls = local.secrets_tls[local.dns_domains.tir],
      # Activation Service
      activation_enable         = var.activation.enable_service,
      activation_name           = var.activation.name_service,
      activation_enable_ingress = var.activation.enable_ingress
      # Verifier
      verifier_enable     = var.verifier.enable_service,
      verifier_name       = var.services_names.verifier,
      verifier_ingress    = var.verifier.enable_ingress,
      verifier_domain     = local.dns_dir[local.dns_domains.verifier],
      verifier_secret_tls = local.secrets_tls[local.dns_domains.verifier],
      # Keycloack
      keycloak_enable         = var.keycloak.enable_service,
      keycloak_name           = var.services_names.keycloak,
      keycloak_ingress        = var.keycloak.enable_ingress,
      keycloak_admin_user     = var.keycloak.admin_user,
      keycloak_admin_password = var.keycloak.admin_password,
      keycloak_db_name        = var.keycloak.db_name,
      keycloak_domain         = local.dns_dir[local.dns_domains.keycloak],
      keycloak_secret_tls     = local.secrets_tls[local.dns_domains.keycloak],
      # Keyrock
      keyrock_enable         = var.keyrock.enable_service,
      keyrock_name           = var.services_names.keyrock,
      keyrock_admin_user     = var.keyrock.admin_user,
      keyrock_admin_password = var.keyrock.admin_password,
      keyrock_admin_email    = var.keyrock.admin_email,
      keyrock_db_name        = var.keyrock.db_name,
      keyrock_ingress        = var.keyrock.enable_ingress,
      keyrock_domain         = local.dns_dir[local.dns_domains.keyrock],
      keyrock_secret_tls     = local.secrets_tls[local.dns_domains.keyrock],
      # PDP
      # Kong
    })
  ]

}
