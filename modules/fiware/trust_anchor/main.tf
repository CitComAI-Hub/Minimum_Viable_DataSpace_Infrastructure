resource "helm_release" "trust_anchor" {
  version          = var.trust_anchor.version
  chart            = var.trust_anchor.chart_name
  repository       = var.trust_anchor.repository
  name             = var.services_names.trust_anchor
  namespace        = var.namespace
  create_namespace = true
  wait             = true

  values = [
    templatefile("${local.helm_yaml_path}/mysql-db.yaml", {
      services_enabled = var.enable_services,
      mysql_host_name  = var.services_names.mysql,
      mysql_config     = var.mysql,
    }),
    templatefile("${local.helm_yaml_path}/trusted-issuers-list.yaml", {
      services_enabled = var.enable_services,
      # Ingress configuration
      ingress_enabled = var.enable_ingress,
      ingress_class   = var.ingress_class,
      # Trusted Issuers List (Trust Anchor)
      til_host_name  = var.services_names.til,
      til_domain     = local.dns_dir[local.dns_domains.til],
      til_secret_tls = local.secrets_tls[local.dns_domains.til],
      tir_domain     = local.dns_dir[local.dns_domains.tir],
      tir_secret_tls = local.secrets_tls[local.dns_domains.tir],
      # MySQL configuration
      mysql_host_name = var.services_names.mysql,
      mysql_config    = var.mysql,
    })
  ]
}
