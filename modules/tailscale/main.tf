resource "kubernetes_namespace" "tailscale" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "kubernetes_secret" "operator_oauth" {
  metadata {
    name      = "operator-oauth"
    namespace = kubernetes_namespace.tailscale.metadata[0].name
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  type = "Opaque"

  data = {
    "client_id"     = var.oauth_client_id
    "client_secret" = var.oauth_client_secret
  }
}

resource "helm_release" "tailscale_operator" {
  name       = "tailscale-operator"
  namespace  = kubernetes_namespace.tailscale.metadata[0].name
  repository = "https://pkgs.tailscale.com/helmcharts"
  chart      = "tailscale-operator"
  version    = var.chart_version

  wait    = true
  timeout = 300

  values = [
    yamlencode({
      operatorConfig = {
        defaultTags = join(",", var.default_tags)
      }
      proxyConfig = {
        defaultTags = join(",", var.default_tags)
      }
    })
  ]

  depends_on = [
    kubernetes_secret.operator_oauth
  ]
}
