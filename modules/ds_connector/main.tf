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
      # Orion-LD
      orionld_enable = var.orion_ld.enable_service,
      orionld_name   = var.services_names.orion_ld,
      # Credentials Config Service
      ccs_enable  = var.credentials_config_service.enable_service,
      ccs_name    = var.services_names.ccs,
      ccs_db_name = var.credentials_config_service.db_name,
      # Trusted Issuers List
      til_enable  = var.trusted_issuers_list.enable_service,
      til_name    = var.services_names.til,
      til_db_name = var.trusted_issuers_list.db_name,
      # Activation Service
      activation_enable         = var.activation.enable_service,
      activation_name           = var.activation.name_service,
      activation_enable_ingress = var.activation.enable_ingress
      # PDP
      # Kong
      # Postgres
      # Walt-ID
      # Verifier
      # Keyrock
      # Keycloack
    })
  ]

}
