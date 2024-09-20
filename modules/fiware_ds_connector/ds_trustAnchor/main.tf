resource "helm_release" "trust_anchor" {
  version          = var.trust_anchor.version
  chart            = var.trust_anchor.chart_name
  repository       = var.trust_anchor.repository
  name             = var.services_names.trust_anchor
  namespace        = var.namespace
  create_namespace = true
  wait             = true

  values = [
    templatefile("${local.helm_conf_yaml_path}/trust_anchor.yaml", {
      # Generate a password for the database connection of trust-anchor.
      generate_passwords_enabled = true,
      # MySQL configuration
      mysql_enabled   = true,
      mysql_secret    = "mysql-database-secret",
      mysql_host_name = var.services_names.mysql,
      mysql_db_name   = "tirdb",
      # Trusted Issuers List (Trust Anchor)
      til_enabled    = true,
      til_host_name  = var.services_names.til,
      til_domain     = local.dns_dir[local.dns_domains.til],
      til_secret_tls = local.secrets_tls[local.dns_domains.til],
      tir_domain     = local.dns_dir[local.dns_domains.tir],
      tir_secret_tls = local.secrets_tls[local.dns_domains.tir],
    })
  ]
}
