resource "helm_release" "trust_anchor" {
  version          = var.trust_anchor.version
  chart            = var.trust_anchor.chart_name
  repository       = var.trust_anchor.repository
  name             = var.services_names.trust_anchor
  namespace        = var.namespace
  create_namespace = true
  wait             = true

  values = [
    #* Authentication (MySQL secret creation)
    templatefile("${local.helm_fiware_pth}/authentication.yaml", {
      services_enabled = var.enable_services,
      mysql_config     = var.mysql,
    }),
    #* MySQL configuration
    templatefile("${local.helm_fiware_pth}/mysql-db.yaml", {
      services_enabled = var.enable_services,
      mysql_host_name  = var.services_names.mysql,
      mysql_config     = var.mysql,
      initdb_scripts   = <<EOT
      CREATE DATABASE ${var.mysql.db_name_til};
      EOT
    }),
    #* Trusted Issuers List
    templatefile("${local.helm_fiware_pth}/trusted-issuers-list.yaml", {
      services_enabled = var.enable_services,
      # Ingress configuration
      ingress_enabled = var.enable_ingress,
      ingress_class   = var.ingress_class,
      tls_enabled     = var.enable_ingress_tls,
      # Trusted Issuers List (Trust Anchor)
      til_host_name  = var.services_names.til,
      til_config     = var.trusted_issuers_list,
      til_domain     = local.dns_dir[local.dns_domains.til],
      til_secret_tls = local.secrets_tls[local.dns_domains.til],
      tir_domain     = local.dns_dir[local.dns_domains.tir],
      tir_secret_tls = local.secrets_tls[local.dns_domains.tir],
      # MySQL configuration
      mysql_host_name = var.services_names.mysql,
      mysql_config    = var.mysql,
    }),
  ]
}
