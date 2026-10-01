# Cluster egress to the Tailnet. Pods cannot resolve nor reach Tailnet names by
# default, so a service that must call another one by its public Tailnet URL (e.g.
# the OIDC issuer https://keycloak.<tailnet>.ts.net) would fail. With egress:
#   1. Each Tailnet name a pod needs gets an ExternalName Service (modules/tailscale/egress),
#      which the operator wires to the egress ProxyGroup.
#   2. The operator's nameserver (DNSConfig) resolves those names to the egress proxies.
#   3. CoreDNS forwards the ts.net zone to that nameserver.
# Traffic then reaches the Tailscale Service through the Tailnet, with its valid certificate.

resource "kubectl_manifest" "egress_proxy_group" {
  count = var.egress_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "tailscale.com/v1alpha1"
    kind       = "ProxyGroup"
    metadata = {
      name = var.egress_proxy_group_name
    }
    spec = {
      type           = "egress"
      replicas       = var.egress_replicas
      hostnamePrefix = var.egress_hostname_prefix
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

resource "kubectl_manifest" "dns_config" {
  count = var.egress_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "tailscale.com/v1alpha1"
    kind       = "DNSConfig"
    metadata = {
      name = "ts-dns"
    }
    spec = {
      nameserver = {
        image = {
          repo = "tailscale/k8s-nameserver"
          tag  = "v${var.chart_version}"
        }
      }
    }
  })

  # The operator publishes the nameserver IP once its Service exists
  wait_for {
    field {
      key        = "status.nameserver.ip"
      value      = "^\\d+\\.\\d+\\.\\d+\\.\\d+$"
      value_type = "regex"
    }
  }

  depends_on = [helm_release.tailscale_operator]
}

data "kubernetes_service" "nameserver" {
  count = var.egress_enabled ? 1 : 0

  metadata {
    name      = "nameserver"
    namespace = kubernetes_namespace.tailscale.metadata[0].name
  }

  depends_on = [kubectl_manifest.dns_config]
}

data "kubernetes_config_map" "coredns" {
  count = var.egress_enabled ? 1 : 0

  metadata {
    name      = "coredns"
    namespace = "kube-system"
  }
}

locals {
  # Current Corefile without the ts.net zone, so the result is stable across applies
  corefile_base = var.egress_enabled ? trimspace(replace(
    data.kubernetes_config_map.coredns[0].data["Corefile"],
    "/\\n*ts\\.net:53 \\{[^}]*\\}/", ""
  )) : ""
}

# Adds the ts.net zone to CoreDNS (the reload plugin applies it within a minute).
# Destroying this resource removes the Corefile key: only destroy it together with
# the cluster, or restore the Corefile.
resource "kubernetes_config_map_v1_data" "coredns" {
  count = var.egress_enabled ? 1 : 0

  metadata {
    name      = "coredns"
    namespace = "kube-system"
  }

  data = {
    Corefile = <<-EOT
      ${local.corefile_base}
      ts.net:53 {
          errors
          cache 30
          forward . ${data.kubernetes_service.nameserver[0].spec[0].cluster_ip}
      }
    EOT
  }

  force = true

  depends_on = [kubectl_manifest.egress_proxy_group]
}
