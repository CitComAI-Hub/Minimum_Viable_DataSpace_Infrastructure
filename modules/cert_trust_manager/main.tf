locals {
  cert_manager_repo = "https://github.com/cert-manager/cert-manager/releases/download/${var.cert_manager_version}/cert-manager.crds.yaml"
}

resource "null_resource" "cert_manager" {
  provisioner "local-exec" {
    command = <<-EOF
      helm repo add jetstack https://charts.jetstack.io --force-update && \
      helm repo update && \
      kubectl apply -f ${local.cert_manager_repo} && \
      helm install cert-manager jetstack/cert-manager \
        --namespace ${var.namespace} \
        --create-namespace \
        --version ${var.cert_manager_version} \
        --wait && \
      helm install trust-manager jetstack/trust-manager \
        --namespace ${var.namespace} \
        --version ${var.trust_manager_version} \
        --wait
    EOF
  }
}
