# Tailscale is the only entry point to the cluster: each service is exposed with
# its own Ingress of class "tailscale", which gives it a Tailnet device
# (https://<hostname>.<tailnet>.ts.net) with an automatic TLS certificate.
module "tailscale" {
  source = "../../../modules/tailscale"

  oauth_client_id     = var.tailscale_oauth_client_id
  oauth_client_secret = var.tailscale_oauth_client_secret
  operator_hostname   = "${var.cluster_name}-ts-operator"
}
