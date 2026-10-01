# Makes a Tailnet name reachable from every pod in the cluster: the operator routes
# this Service through the egress ProxyGroup and its nameserver resolves the name,
# so pods use the same https://<fqdn> URL (and certificate) as any Tailnet device.
resource "kubernetes_service" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace
    annotations = {
      "tailscale.com/tailnet-fqdn" = var.fqdn
      "tailscale.com/proxy-group"  = var.proxy_group
    }
  }

  spec {
    type = "ExternalName"
    # The operator replaces it with the egress proxy Service
    external_name = "placeholder"

    dynamic "port" {
      for_each = var.ports
      content {
        name     = "tcp-${port.value}"
        port     = port.value
        protocol = "TCP"
      }
    }
  }

  lifecycle {
    ignore_changes = [spec[0].external_name]
  }
}
