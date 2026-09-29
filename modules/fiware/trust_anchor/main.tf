resource "helm_release" "trust_anchor" {
  name       = var.release_name
  repository = var.trust_anchor.repository
  chart      = var.trust_anchor.chart_name
  version    = var.trust_anchor.version

  create_namespace = true
  namespace        = var.namespace

  wait    = true
  timeout = 600

  values = concat([
    templatefile("${path.module}/values.yaml", {
      postgres_operator_enabled = var.postgres_operator_enabled
      managed_postgres_enabled  = var.managed_postgres_enabled
      ingress_enabled           = var.ingress_enabled
      ingress_class_name        = var.ingress_class_name
      tir_hostname              = var.tir_hostname
      til_hostname              = var.til_hostname
    })
  ], var.extra_values)
}
