resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  namespace        = var.eso_namespace
  create_namespace = true

  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = var.eso_chart_version

  # Wait for the CRDs and the webhook before anyone creates SecretStore/ExternalSecret
  wait    = true
  timeout = 600
}
