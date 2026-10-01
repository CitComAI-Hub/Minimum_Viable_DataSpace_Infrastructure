# MagicDNS domain of the Tailnet (e.g. tail1234.ts.net), needed to build the public
# URLs that services must know (OIDC issuer, redirect URIs...). It is taken from the
# state Secret of the first ingress proxy, where Tailscale writes the device FQDN as
# soon as the proxy joins the Tailnet, so it does not depend on any TLS certificate.
data "kubernetes_secret" "ingress_proxy_state" {
  metadata {
    name      = "${var.proxy_group_name}-0"
    namespace = kubernetes_namespace.tailscale.metadata[0].name
  }

  depends_on = [kubectl_manifest.proxy_group]
}

locals {
  # "<host>.<tailnet>.ts.net." -> "<tailnet>.ts.net" (the FQDN is not sensitive)
  proxy_fqdn     = trimsuffix(nonsensitive(data.kubernetes_secret.ingress_proxy_state.data["device_fqdn"]), ".")
  tailnet_domain = join(".", slice(split(".", local.proxy_fqdn), 1, length(split(".", local.proxy_fqdn))))
}

# Published in the cluster so layers with their own state can read it without
# knowing the operator internals
resource "kubernetes_config_map" "tailnet" {
  metadata {
    name      = "tailnet"
    namespace = kubernetes_namespace.tailscale.metadata[0].name
  }

  data = {
    domain = local.tailnet_domain
  }
}
