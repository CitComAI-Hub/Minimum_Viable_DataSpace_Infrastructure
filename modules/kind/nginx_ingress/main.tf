################################################################################
# Admission webhook
################################################################################

resource "kubernetes_service_account" "ingress_nginx_admission" {
  
  metadata {
    name      = "ingress-nginx-admission"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/component" = "admission-webhook"
      "app.kubernetes.io/instance"  = var.namespace
      "app.kubernetes.io/name"      = var.namespace
      "app.kubernetes.io/part-of"   = var.namespace
      "app.kubernetes.io/version"   = "1.11.2"
    }
  }

  automount_service_account_token = true
}

resource "kubernetes_role" "ingress_nginx_admission" {
  
  metadata {
    name      = "ingress-nginx-admission"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/component" = "admission-webhook"
      "app.kubernetes.io/instance"  = var.namespace
      "app.kubernetes.io/name"      = var.namespace
      "app.kubernetes.io/part-of"   = var.namespace
      "app.kubernetes.io/version"   = "1.11.2"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "create"]
  }
}

resource "kubernetes_cluster_role" "ingress_nginx_admission" {
  
  metadata {
    name = "ingress-nginx-admission"
    labels = {
      "app.kubernetes.io/component" = "admission-webhook"
      "app.kubernetes.io/instance"  = var.namespace
      "app.kubernetes.io/name"      = var.namespace
      "app.kubernetes.io/part-of"   = var.namespace
      "app.kubernetes.io/version"   = "1.11.2"
    }
  }

  rule {
    api_groups = ["admissionregistration.k8s.io"]
    resources  = ["validatingwebhookconfigurations"]
    verbs      = ["get", "update"]
  }
}

resource "kubernetes_role_binding" "ingress_nginx_admission" {
  
  metadata {
    name      = "ingress-nginx-admission"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/component" = "admission-webhook"
      "app.kubernetes.io/instance"  = var.namespace
      "app.kubernetes.io/name"      = var.namespace
      "app.kubernetes.io/part-of"   = var.namespace
      "app.kubernetes.io/version"   = "1.11.2"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "ingress-nginx-admission"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "ingress-nginx-admission"
    namespace = var.namespace
  }
}

resource "kubernetes_cluster_role_binding" "ingress_nginx_admission" {
  
  metadata {
    name = "ingress-nginx-admission"
    labels = {
      "app.kubernetes.io/component" = "admission-webhook"
      "app.kubernetes.io/instance"  = var.namespace
      "app.kubernetes.io/name"      = var.namespace
      "app.kubernetes.io/part-of"   = var.namespace
      "app.kubernetes.io/version"   = "1.11.2"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "ingress-nginx-admission"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "ingress-nginx-admission"
    namespace = var.namespace
  }
}


resource "kubernetes_job" "ingress_nginx_admission_create" {
  
  metadata {
    name      = "ingress-nginx-admission-create"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/component" = "admission-webhook"
      "app.kubernetes.io/instance"  = var.namespace
      "app.kubernetes.io/name"      = var.namespace
      "app.kubernetes.io/part-of"   = var.namespace
      "app.kubernetes.io/version"   = "1.11.2"
    }
  }

  spec {
    template {
      metadata {
        name = "ingress-nginx-admission-create"
        labels = {
          "app.kubernetes.io/component" = "admission-webhook"
          "app.kubernetes.io/instance"  = var.namespace
          "app.kubernetes.io/name"      = var.namespace
          "app.kubernetes.io/part-of"   = var.namespace
          "app.kubernetes.io/version"   = "1.11.2"
        }
      }
      spec {
        container {
          args = [
            "create",
            "--host=ingress-nginx-controller-admission,ingress-nginx-controller-admission.$(POD_NAMESPACE).svc",
            "--namespace=$(POD_NAMESPACE)",
            "--secret-name=ingress-nginx-admission"
          ]
          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
          image             = "registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.3@sha256:a320a50cc91bd15fd2d6fa6de58bd98c1bd64b9a6f926ce23a600d87043455a3"
          image_pull_policy = "IfNotPresent"
          name              = "create"
          security_context {
            allow_privilege_escalation = false
            capabilities {
              drop = ["ALL"]
            }
            read_only_root_filesystem = true
            run_as_non_root           = true
            run_as_user               = 65532
            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
        }
        node_selector = {
          "kubernetes.io/os" = "linux"
        }
        restart_policy       = "OnFailure"
        service_account_name = "ingress-nginx-admission"
      }
    }
  }
}

resource "kubernetes_job" "ingress_nginx_admission_patch" {
  
  metadata {
    name      = "ingress-nginx-admission-patch"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/component" = "admission-webhook"
      "app.kubernetes.io/instance"  = var.namespace
      "app.kubernetes.io/name"      = var.namespace
      "app.kubernetes.io/part-of"   = var.namespace
      "app.kubernetes.io/version"   = "1.11.2"
    }
  }

  spec {
    template {
      metadata {
        name = "ingress-nginx-admission-patch"
        labels = {
          "app.kubernetes.io/component" = "admission-webhook"
          "app.kubernetes.io/instance"  = var.namespace
          "app.kubernetes.io/name"      = var.namespace
          "app.kubernetes.io/part-of"   = var.namespace
          "app.kubernetes.io/version"   = "1.11.2"
        }
      }
      spec {
        container {
          args = [
            "patch",
            "--webhook-name=ingress-nginx-admission",
            "--namespace=$(POD_NAMESPACE)",
            "--patch-mutating=false",
            "--secret-name=ingress-nginx-admission",
            "--patch-failure-policy=Fail"
          ]
          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
          image             = "registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.3@sha256:a320a50cc91bd15fd2d6fa6de58bd98c1bd64b9a6f926ce23a600d87043455a3"
          image_pull_policy = "IfNotPresent"
          name              = "patch"
          security_context {
            allow_privilege_escalation = false
            capabilities {
              drop = ["ALL"]
            }
            read_only_root_filesystem = true
            run_as_non_root           = true
            run_as_user               = 65532
            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
        }
        node_selector = {
          "kubernetes.io/os" = "linux"
        }
        restart_policy       = "OnFailure"
        service_account_name = "ingress-nginx-admission"
      }
    }
  }
}

resource "kubernetes_validating_webhook_configuration" "ingress_nginx_admission" {
  
  metadata {
    name = "ingress-nginx-admission"
    labels = {
      "app.kubernetes.io/component" = "admission-webhook"
      "app.kubernetes.io/instance"  = var.namespace
      "app.kubernetes.io/name"      = var.namespace
      "app.kubernetes.io/part-of"   = var.namespace
      "app.kubernetes.io/version"   = "1.11.2"
    }
  }

  webhook {
    admission_review_versions = ["v1"]
    client_config {
      service {
        name      = "ingress-nginx-controller-admission"
        namespace = var.namespace
        path      = "/networking/v1/ingresses"
      }
    }
    failure_policy = "Fail"
    match_policy   = "Equivalent"
    name           = "validate.nginx.ingress.kubernetes.io"
    rule {
      api_groups   = ["networking.k8s.io"]
      api_versions = ["v1"]
      operations   = ["CREATE", "UPDATE"]
      resources    = ["ingresses"]
    }
    side_effects = "None"
  }
}


################################################################################
# Controller
################################################################################
resource "kubernetes_config_map" "ingress_nginx_controller" {
  
  metadata {
    name      = "ingress-nginx-controller"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/instance"  = var.namespace
      "app.kubernetes.io/name"      = var.namespace
      "app.kubernetes.io/part-of"   = var.namespace
      "app.kubernetes.io/version"   = "1.11.2"
    }
  }

  data = {
    allow-snippet-annotations = "false"
  }
}

resource "kubernetes_service" "ingress_nginx_controller" {
  
  metadata {
    name      = "ingress-nginx-controller"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/instance"  = var.namespace
      "app.kubernetes.io/name"      = var.namespace
      "app.kubernetes.io/part-of"   = var.namespace
      "app.kubernetes.io/version"   = "1.11.2"
    }
  }

  spec {
    type             = var.service_type
    ip_families      = ["IPv4"]
    ip_family_policy = "SingleStack"
    dynamic "port" {
      for_each = var.add_ports
      content {
        app_protocol = port.value.app_protocol
        name         = port.value.name
        port         = port.value.port
        protocol     = port.value.protocol
        target_port  = port.value.target_port
      }
    }
    selector = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/instance"  = var.namespace
      "app.kubernetes.io/name"      = var.namespace
    }
  }
}

resource "kubernetes_service" "ingress_nginx_controller_admission" {
  
  metadata {
    name      = "ingress-nginx-controller-admission"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/instance"  = var.namespace
      "app.kubernetes.io/name"      = var.namespace
      "app.kubernetes.io/part-of"   = var.namespace
      "app.kubernetes.io/version"   = "1.11.2"
    }
  }

  spec {
    port {
      app_protocol = "https"
      name         = "https-webhook"
      port         = 443
      target_port  = "webhook"
    }
    selector = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/instance"  = var.namespace
      "app.kubernetes.io/name"      = var.namespace
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "ingress_nginx_controller" {
  
  metadata {
    name      = "ingress-nginx-controller"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/instance"  = var.namespace
      "app.kubernetes.io/name"      = var.namespace
      "app.kubernetes.io/part-of"   = var.namespace
      "app.kubernetes.io/version"   = "1.11.2"
    }
  }

  spec {
    min_ready_seconds      = 0
    revision_history_limit = 10
    selector {
      match_labels = {
        "app.kubernetes.io/component" = "controller"
        "app.kubernetes.io/instance"  = var.namespace
        "app.kubernetes.io/name"      = var.namespace
      }
    }
    strategy {
      rolling_update {
        max_unavailable = 1
      }
      type = "RollingUpdate"
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/component" = "controller"
          "app.kubernetes.io/instance"  = var.namespace
          "app.kubernetes.io/name"      = var.namespace
          "app.kubernetes.io/part-of"   = var.namespace
          "app.kubernetes.io/version"   = "1.11.2"
        }
      }
      spec {
        container {
          image             = "registry.k8s.io/ingress-nginx/controller:v1.11.2@sha256:d5f8217feeac4887cb1ed21f27c2674e58be06bd8f5184cacea2a69abaf78dce"
          image_pull_policy = "IfNotPresent"
          name              = "controller"
          resources {
            requests = {
              cpu    = "100m"
              memory = "90Mi"
            }
          }
          args = [
            "/nginx-ingress-controller",
            "--election-id=ingress-nginx-leader",
            "--controller-class=k8s.io/ingress-nginx",
            "--ingress-class=nginx",
            "--configmap=$(POD_NAMESPACE)/ingress-nginx-controller",
            "--validating-webhook=:8443",
            "--validating-webhook-certificate=/usr/local/certificates/cert",
            "--validating-webhook-key=/usr/local/certificates/key",
            "--watch-ingress-without-class=true",
            "--enable-metrics=false",
            "--publish-status-address=localhost"
          ]
          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }
          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
          env {
            name  = "LD_PRELOAD"
            value = "/usr/local/lib/libmimalloc.so"
          }
          lifecycle {
            pre_stop {
              exec {
                command = ["/wait-shutdown"]
              }
            }
          }
          liveness_probe {
            failure_threshold = 5
            http_get {
              path   = "/healthz"
              port   = 10254
              scheme = "HTTP"
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 1
          }
          port {
            container_port = 80
            host_port      = 80
            name           = "http"
            protocol       = "TCP"
          }
          port {
            container_port = 443
            host_port      = 443
            name           = "https"
            protocol       = "TCP"
          }
          port {
            container_port = 8443
            name           = "webhook"
            protocol       = "TCP"
          }
          readiness_probe {
            failure_threshold = 3
            http_get {
              path   = "/healthz"
              port   = 10254
              scheme = "HTTP"
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 1
          }
          security_context {
            allow_privilege_escalation = false
            capabilities {
              add  = ["NET_BIND_SERVICE"]
              drop = ["ALL"]
            }
            read_only_root_filesystem = false
            run_as_non_root           = true
            run_as_user               = 101
            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
          volume_mount {
            mount_path = "/usr/local/certificates/"
            name       = "webhook-cert"
            read_only  = true
          }
        }
        dns_policy = "ClusterFirst"
        node_selector = {
          "ingress-ready"    = "true"
          "kubernetes.io/os" = "linux"
        }
        service_account_name             = var.namespace
        termination_grace_period_seconds = 0
        toleration {
          effect   = "NoSchedule"
          key      = "node-role.kubernetes.io/master"
          operator = "Equal"
        }
        toleration {
          effect   = "NoSchedule"
          key      = "node-role.kubernetes.io/control-plane"
          operator = "Equal"
        }
        volume {
          name = "webhook-cert"
          secret {
            secret_name = "ingress-nginx-admission"
          }
        }
      }
    }
  }
}


################################################################################
# Nginx
################################################################################
resource "kubernetes_namespace" "ingress_nginx" {
  
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/instance" = var.namespace
      "app.kubernetes.io/name"     = var.namespace
    }
  }
}

resource "kubernetes_service_account" "ingress_nginx" {
  
  metadata {
    name      = var.namespace
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/instance"  = var.namespace
      "app.kubernetes.io/name"      = var.namespace
      "app.kubernetes.io/part-of"   = var.namespace
      "app.kubernetes.io/version"   = "1.11.2"
    }
  }

  automount_service_account_token = true
}

resource "kubernetes_role" "ingress_nginx" {
  
  metadata {
    name      = var.namespace
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/instance"  = var.namespace
      "app.kubernetes.io/name"      = var.namespace
      "app.kubernetes.io/part-of"   = var.namespace
      "app.kubernetes.io/version"   = "1.11.2"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["get"]
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps", "pods", "secrets", "endpoints"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["services"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses/status"]
    verbs      = ["update"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingressclasses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups     = ["coordination.k8s.io"]
    resource_names = ["ingress-nginx-leader"]
    resources      = ["leases"]
    verbs          = ["get", "update"]
  }

  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["create"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["create", "patch"]
  }

  rule {
    api_groups = ["discovery.k8s.io"]
    resources  = ["endpointslices"]
    verbs      = ["list", "watch", "get"]
  }
}

resource "kubernetes_cluster_role" "ingress_nginx" {
  
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/instance" = var.namespace
      "app.kubernetes.io/name"     = var.namespace
      "app.kubernetes.io/part-of"  = var.namespace
      "app.kubernetes.io/version"  = "1.11.2"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps", "endpoints", "nodes", "pods", "secrets", "namespaces"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get"]
  }

  rule {
    api_groups = [""]
    resources  = ["services"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["create", "patch"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses/status"]
    verbs      = ["update"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingressclasses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["discovery.k8s.io"]
    resources  = ["endpointslices"]
    verbs      = ["list", "watch", "get"]
  }
}

resource "kubernetes_role_binding" "ingress_nginx" {
  
  metadata {
    name      = var.namespace
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/instance"  = var.namespace
      "app.kubernetes.io/name"      = var.namespace
      "app.kubernetes.io/part-of"   = var.namespace
      "app.kubernetes.io/version"   = "1.11.2"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = var.namespace
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.namespace
    namespace = var.namespace
  }
}

resource "kubernetes_cluster_role_binding" "ingress_nginx" {
  
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/instance" = var.namespace
      "app.kubernetes.io/name"     = var.namespace
      "app.kubernetes.io/part-of"  = var.namespace
      "app.kubernetes.io/version"  = "1.11.2"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = var.namespace
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.namespace
    namespace = var.namespace
  }
}

resource "kubernetes_ingress_class" "nginx" {
  
  metadata {
    name = "nginx"
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/instance"  = var.namespace
      "app.kubernetes.io/name"      = var.namespace
      "app.kubernetes.io/part-of"   = var.namespace
      "app.kubernetes.io/version"   = "1.11.2"
    }
  }

  spec {
    controller = "k8s.io/ingress-nginx"
  }
}
