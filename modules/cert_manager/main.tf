resource "null_resource" "cert_manager" {
  provisioner "local-exec" {
    command = <<-EOF
      helm repo add jetstack https://charts.jetstack.io --force-update && \
      helm repo update && \
      kubectl apply -f ${var.cert_manager_version} && \
      helm install \
        cert-manager jetstack/cert-manager \
        --namespace ${var.namespace} \
        --create-namespace \
        --version v1.14.3 && \
      kubectl wait --namespace cert-manager \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=90s
    EOF
  }
}