locals {
  ca_path = "${path.module}/${var.data_ca_path}"
}

resource "null_resource" "create_ca_certificates" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/generate_ca_certificates.sh ${local.ca_path}"
  }
}

data "local_file" "ca_certificates" {
  depends_on = [null_resource.create_ca_certificates]
  for_each = {
    #! Terraform encode automatically to base64
    ca_cert = "${local.ca_path}/ca.crt"
    ca_key  = "${local.ca_path}/ca.key"
  }
  filename = each.value
}

resource "kubernetes_secret" "secret_ca_certificates" {
  depends_on = [data.local_file.ca_certificates]
  metadata {
    name      = var.secret_ca_container
    namespace = var.namespace
  }
  type = "Opaque"
  data = {
    "tls.crt" = data.local_file.ca_certificates["ca_cert"].content
    "tls.key" = data.local_file.ca_certificates["ca_key"].content
  }
}

resource "kubernetes_manifest" "cert_manager" {
  depends_on = [kubernetes_secret.secret_ca_certificates]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = var.clusterissuer_name
    }
    spec = {
      ca = {
        secretName = var.secret_ca_container
      }
    }
  }
}

# FIXME: It's working but maybe it's not the best way to do it.
resource "kubernetes_manifest" "bundle_trust_manager" {
  depends_on = [kubernetes_secret.secret_ca_certificates]
  manifest = {
    apiVersion = "trust.cert-manager.io/v1alpha1"
    kind       = "Bundle"
    metadata = {
      name = "public-bundle"
    }
    spec = {
      sources = [{
        secret = {
          name      = var.secret_ca_container
          namespace = var.namespace
          key       = "tls.crt"
        }
      }]
      target = {
        configMap = {
          key = "my-ca-certificate.crt"
        }
        namespaceSelector = {
          matchLabels = {
            trust = "enabled"
          }
        }
      }
    }
  }
}
