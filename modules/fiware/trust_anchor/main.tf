resource "helm_release" "trust_anchor" {
  name       = var.release_name
  repository = var.trust_anchor.repository
  chart      = var.trust_anchor.chart_name
  version    = var.trust_anchor.version

  create_namespace = true
  namespace        = var.namespace

  wait    = true
  timeout = 600

  # values = concat([yamlencode(local.chart_values)], var.extra_values)
  values = [
    templatefile("./values.yaml", {
      postgres_operator_enabled = var.postgres_operator_enabled
      managed_postgres_enabled  = var.managed_postgres_enabled
      tailscale_enabled         = var.tailscale_enabled
      tailscale_hostname        = var.tailscale_hostname
  })]
}
