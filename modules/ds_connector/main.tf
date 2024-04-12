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
      mongodb_name          = var.mongodb.name_service,
      mongodb_auth_enable   = var.mongodb.auth_enabled,
      mongodb_root_password = var.mongodb.root_password,
      # MySQL
      mysql_enable        = var.mysql.enable_service,
      mysql_name          = var.mysql.name_service,
      mysql_root_password = var.mysql.root_password,
      mysql_password      = var.mysql.root_password,
      # Credentials Config Service
      ccs_enable  = var.credentials_config_service.enable_service,
      ccs_name    = var.credentials_config_service.name_service,
      ccs_db_name = var.credentials_config_service.db_name,
      # Activation Service
      activation_enable         = var.activation.enable_service,
      activation_name           = var.activation.name_service,
      activation_enable_ingress = var.activation.enable_ingress
      # PDP
      # Kong
      # Orion-LD
      # Postgres
      # Trusted Issuers List
      # Walt-ID
      # Verifier
      # Keyrock
      # Keycloack
    })
  ]

}
