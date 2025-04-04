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
      ingress_class    = var.ingress_class,
      ingress_enabled  = var.enable_ingress,
      services_enabled = var.enable_services,
      # MySQL configuration
      mysql_host_name = var.services_names.mysql,
      mysql_config    = var.mysql,
      # Trusted Issuers List (Trust Anchor)
      til_host_name  = var.services_names.til,
      til_domain     = local.dns_dir[local.dns_domains.til],
      til_secret_tls = local.secrets_tls[local.dns_domains.til],
      tir_domain     = local.dns_dir[local.dns_domains.tir],
      tir_secret_tls = local.secrets_tls[local.dns_domains.tir],
    })
  ]
}
