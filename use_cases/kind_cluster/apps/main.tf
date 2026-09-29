# Tailscale es el único punto de entrada al clúster: cada servicio se expone con
# su propio Ingress de clase "tailscale", que le da un dispositivo en la Tailnet
# (https://<hostname>.<tailnet>.ts.net) con certificado TLS automático.
module "tailscale" {
  source = "../../../modules/tailscale"

  oauth_client_id     = var.tailscale_oauth_client_id
  oauth_client_secret = var.tailscale_oauth_client_secret
  operator_hostname   = "${var.cluster_name}-ts-operator"
}
