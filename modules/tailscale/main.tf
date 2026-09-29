locals {
  proxy_class_name = "default"
}

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
        hostname    = var.operator_hostname
        defaultTags = join(",", var.operator_tags)
      }
      # Defaults for every proxy and Tailscale Service, so Ingresses only need
      # the proxy-group annotation
      proxyConfig = {
        defaultTags       = join(",", var.proxy_tags)
        defaultProxyClass = local.proxy_class_name
      }
    })
  ]

  depends_on = [
    kubernetes_secret.operator_oauth
  ]
}

# Settings shared by every proxy. useLetsEncryptStagingEnvironment switches the
# Let's Encrypt environment of the Ingress certificates.
resource "kubectl_manifest" "proxy_class" {
  yaml_body = yamlencode({
    apiVersion = "tailscale.com/v1alpha1"
    kind       = "ProxyClass"
    metadata = {
      name = local.proxy_class_name
    }
    # Only set when true: the API server drops the false default, which would
    # otherwise show up as a change on every plan
    spec = { for k, v in { useLetsEncryptStagingEnvironment = true } : k => v if var.letsencrypt_staging }
  })

  # The ProxyClass CRD is installed by the operator chart
  depends_on = [helm_release.tailscale_operator]
}

# Shared proxies for every Ingress annotated with tailscale.com/proxy-group. Each
# Ingress becomes a Tailscale Service with its own hostname and TLS certificate,
# while the Tailnet only gets one device per replica instead of one per Ingress.
resource "kubectl_manifest" "proxy_group" {
  yaml_body = yamlencode({
    apiVersion = "tailscale.com/v1alpha1"
    kind       = "ProxyGroup"
    metadata = {
      name = var.proxy_group_name
    }
    spec = {
      type           = "ingress"
      replicas       = var.proxy_group_replicas
      hostnamePrefix = var.proxy_group_hostname_prefix
      proxyClass     = local.proxy_class_name
      # Tags cannot change once the devices exist
      tags = var.proxy_tags
    }
  })

  wait_for {
    condition {
      type   = "ProxyGroupReady"
      status = "True"
    }
  }

  depends_on = [kubectl_manifest.proxy_class]
}
