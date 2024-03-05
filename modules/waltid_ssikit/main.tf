locals {
  namespace         = "did-server"
  web_server        = "web-server"
  nginx_data_path   = "${path.module}/${var.nginx_data_path}"
  nginx_conf_path   = "${path.module}/${var.nginx_conf_path}"
  nginx_conf_secret = "nginx-config-secret"
}


resource "kubernetes_namespace" "namespace_ssikit" {
  metadata {
    name = var.namespace
    labels = {
      trust = "enabled"
    }
  }
}

################################################################################
# Wali-ID SSI-Kit
################################################################################
resource "kubernetes_deployment" "waltid_ssikit" {
  depends_on = [kubernetes_namespace.namespace_ssikit]
  metadata {
    name      = "waltid-ssikit"
    namespace = var.namespace
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "waltid-ssikit"
      }
    }
    template {
      metadata {
        labels = {
          app = "waltid-ssikit"
        }
      }
      spec {
        volume {
          name = "volume-ssikit" #TODO: Change to a variable
          host_path {
            path = "/etc/kubernetes/data/ssikit"
            type = "Directory"
          }
        }
        #FIXME: This is a temporary solution.
        volume {
          name = "my-ca-certificate"
          config_map {
            name         = "public-bundle"
            default_mode = "0644"
            optional     = false
            items {
              key  = "my-ca-certificate.crt"
              path = "my-ca-certificate.crt"
            }
          }
        }
        container {
          image = "waltid/ssikit:latest"
          name  = "waltid-ssikit"
          # Override the entry point to keep the container running
          command = ["/bin/sh", "-c", "tail -f /dev/null"]
          # Mount volumen to get didweb certificates
          volume_mount {
            name       = "volume-ssikit"
            mount_path = "/app/data"
          }
          # FIXME: This is a temporary solution. The CA certificates are not 
          # fully recognized by the container.
          volume_mount {
            name       = "my-ca-certificate"
            mount_path = "/etc/ssl/certs/my-certificates"
            read_only  = true
          }
        }
      }
    }
  }
}

################################################################################
# Web Server
################################################################################
data "local_file" "nginx_config" {
  for_each = {
    conf_file = "${local.nginx_conf_path}/default.conf"
  }
  filename = each.value
}

resource "kubernetes_secret" "web_server_nginx_conf" {
  depends_on = [kubernetes_namespace.namespace_ssikit]
  metadata {
    name      = local.nginx_conf_secret
    namespace = var.namespace
  }
  type = "Opaque"
  data = {
    "default.conf" = data.local_file.nginx_config["conf_file"].content
  }
}

resource "kubernetes_manifest" "did_web_certs" {
  # Create a certificate for the web server
  # kubectl get cert --all-namespaces
  depends_on = [kubernetes_namespace.namespace_ssikit]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "nginx-certificate"
      namespace = var.namespace
    }
    spec = {
      secretName = "nginx-tls-secret"
      issuerRef = {
        name = var.ca_clusterissuer_name
        kind = "ClusterIssuer"
      }
      dnsNames = [local.web_server]
    }
  }
}

resource "kubernetes_deployment" "did_web_server" {
  depends_on = [kubernetes_secret.web_server_nginx_conf]
  metadata {
    name      = local.web_server
    namespace = var.namespace
    labels = {
      app = "waltid-web"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "waltid-web"
      }
    }
    template {
      metadata {
        labels = {
          app = "waltid-web"
        }
      }
      spec {
        container {
          image = "nginx:${var.nginx_version}"
          name  = local.web_server
          dynamic "port" {
            for_each = var.nginx_port
            content {
              container_port = port.value.container_port
            }
          }
          dynamic "volume_mount" {
            for_each = var.nginx_volume_mount
            content {
              name       = volume_mount.value.name
              mount_path = volume_mount.value.mount_path
            }

          }
        }
        # Add config file to the container (needs to restart to apply changes)
        volume {
          name = "nginx-conf" #TODO: Change to a variable
          secret {
            secret_name = local.nginx_conf_secret
          }
        }
        # Add certificates created by cert-manager
        volume {
          name = "nginx-ssl-certs" #TODO: Change to a variable
          secret {
            secret_name = "nginx-tls-secret" #TODO: Change to a variable
          }
        }
        # Mount the volume to the container
        volume {
          name = "nginx-web-data" #TODO: Change to a variable
          host_path {
            path = var.nginx_volume_path
            type = "Directory"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "did_web_server" {
  depends_on = [kubernetes_deployment.did_web_server]
  metadata {
    name      = local.web_server
    namespace = var.namespace
  }
  spec {
    selector = {
      app = kubernetes_deployment.did_web_server.metadata.0.labels.app
    }
    session_affinity = "ClientIP"
    port {
      name        = "http"
      port        = 80
      target_port = 80
    }
    port {
      name        = "https"
      port        = 443
      target_port = 443
    }
    type = "ClusterIP"
  }
}
