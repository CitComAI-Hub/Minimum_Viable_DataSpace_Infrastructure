# CloudNativePG operator: installed once per cluster, it manages every PostgreSQL
# instance deployed with modules/postgres.
resource "helm_release" "cnpg" {
  name             = "cnpg"
  namespace        = var.namespace
  create_namespace = true

  repository = "https://cloudnative-pg.github.io/charts"
  chart      = "cloudnative-pg"
  version    = var.chart_version

  # Wait for the operator and its admission webhook before any Cluster is created
  wait    = true
  timeout = 600
}
