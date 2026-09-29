resource "kubernetes_namespace" "traefik" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "helm_release" "traefik" {
  name       = "traefik"
  namespace  = kubernetes_namespace.traefik.metadata[0].name
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  version    = var.chart_version

  # Wait for all pods to be ready before the apply is considered successful
  wait    = true
  timeout = 300

  # --- Deployment mode ---
  # DaemonSet ensures Traefik runs on the Kind control-plane node,
  # which has the container ports 80/443 mapped to the host.
  set {
    name  = "deployment.kind"
    value = "DaemonSet"
  }

  # --- Service ---
  # ClusterIP: Kind has no native LoadBalancer. Traffic arrives
  # directly through hostPort from the host.
  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  # --- HTTP / HTTPS ports with hostPort ---
  # Binds the container ports to the node ports, which Kind maps to the host.
  set {
    name  = "ports.web.hostPort"
    value = var.web_host_port
  }
  set {
    name  = "ports.websecure.hostPort"
    value = var.websecure_host_port
  }

  # --- NodeSelector ---
  # Targets only the control-plane node labelled by the kind module.
  # type = "string" stops Helm from casting "true" to a boolean, which
  # breaks the PodSpec that expects nodeSelector as map[string]string.
  set {
    name  = "nodeSelector.ingress-ready"
    value = "true"
    type  = "string"
  }

  # --- Tolerations ---
  # The control-plane has the NoSchedule taint; it must be tolerated explicitly.
  set {
    name  = "tolerations[0].key"
    value = "node-role.kubernetes.io/control-plane"
  }
  set {
    name  = "tolerations[0].operator"
    value = "Exists"
  }
  set {
    name  = "tolerations[0].effect"
    value = "NoSchedule"
  }
  set {
    name  = "tolerations[1].key"
    value = "node-role.kubernetes.io/master"
  }
  set {
    name  = "tolerations[1].operator"
    value = "Exists"
  }
  set {
    name  = "tolerations[1].effect"
    value = "NoSchedule"
  }

  # --- Providers ---
  set {
    name  = "providers.kubernetesIngress.enabled"
    value = "true"
  }
  set {
    name  = "providers.kubernetesCRD.enabled"
    value = "true"
  }

  # --- Dashboard ---
  # Exposes the dashboard through an IngressRoute; external access is handled
  # by the use case.
  set {
    name  = "ingressRoute.dashboard.enabled"
    value = tostring(var.dashboard_enabled)
  }
  set {
    name  = "ingressRoute.dashboard.matchRule"
    value = "PathPrefix(`/dashboard`) || PathPrefix(`/api`)"
  }
  set {
    name  = "ingressRoute.dashboard.entryPoints[0]"
    value = "web"
  }

  # JSON logs to ease a future integration with observability tools
  set {
    name  = "logs.general.format"
    value = "json"
  }
  set {
    name  = "logs.access.enabled"
    value = "true"
  }
  set {
    name  = "logs.access.format"
    value = "json"
  }
}

