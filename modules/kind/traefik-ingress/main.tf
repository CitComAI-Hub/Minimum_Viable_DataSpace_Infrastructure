# # https://doc.traefik.io/traefik/getting-started/quick-start-with-kubernetes/

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_ingress_class" "traefik" {
  metadata {
    name = "traefik"
  }
  spec {
    controller = "traefik.io/ingress-controller"
  }
}

resource "kubernetes_cluster_role" "role" {
  depends_on = [kubernetes_namespace.namespace]
  metadata {
    name = "traefik-role"
  }

  rule {
    api_groups = [""]
    resources  = ["services", "secrets", "nodes"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["discovery.k8s.io"]
    resources  = ["endpointslices"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses", "ingressclasses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses/status"]
    verbs      = ["update"]
  }

  rule {
    api_groups = ["traefik.io"]
    resources = [
      "middlewares", "middlewaretcps", "ingressroutes", "traefikservices",
      "ingressroutetcps", "ingressrouteudps", "tlsoptions", "tlsstores",
      "serverstransports", "serverstransporttcps"
    ]
    verbs = ["get", "list", "watch"]
  }
}

resource "kubernetes_service_account" "account" {
  depends_on = [kubernetes_namespace.namespace]
  metadata {
    name      = "traefik-account"
    namespace = var.namespace
  }
}

resource "kubernetes_cluster_role_binding" "role_binding" {
  depends_on = [kubernetes_namespace.namespace]

  metadata {
    name = "traefik-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.account.metadata[0].name
    namespace = var.namespace
  }
}

resource "kubernetes_manifest" "deployment" {
  depends_on = [kubernetes_namespace.namespace]
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = "traefik-deployment"
      namespace = var.namespace
      labels = {
        app = "traefik"
      }
    }
    spec = {
      replicas = 1
      selector = {
        matchLabels = {
          app = "traefik"
        }
      }
      template = {
        metadata = {
          labels = {
            app = "traefik"
          }
        }
        spec = {
          serviceAccountName = "traefik-account"
          containers = [
            {
              name  = "traefik"
              image = "traefik:v3.1"
              args = [
                "--api.insecure=true",
                "--api.dashboard=true",
                "--providers.kubernetesingress=true",
                "--global.checknewversion=false",
                "--global.sendAnonymousUsage=false",
                "--entryPoints.web.address=:80"
              ]
              ports = [
                {
                  name          = "web"
                  containerPort = 80
                },
                {
                  name          = "dashboard"
                  containerPort = 8080
                }
              ]
            }
          ]
        }
      }
    }
  }
}

resource "kubernetes_service" "traefik_web_service" {
  depends_on = [kubernetes_namespace.namespace]
  metadata {
    name      = "traefik-web-service"
    namespace = var.namespace
  }
  spec {
    type = "LoadBalancer"
    port {
      port        = 80
      target_port = "web"
    }
    selector = {
      app = "traefik"
    }
  }
}

resource "kubernetes_service" "traefik_dashboard_service" {
  depends_on = [kubernetes_namespace.namespace, kubernetes_service.traefik_web_service]
  metadata {
    name      = "traefik-dashboard-service"
    namespace = var.namespace
  }
  spec {
    type = "LoadBalancer"
    port {
      port        = 8080
      target_port = "dashboard"
    }
    selector = {
      app = "traefik"
    }
  }
}
