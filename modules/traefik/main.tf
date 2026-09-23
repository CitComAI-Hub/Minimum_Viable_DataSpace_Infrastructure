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

  # Espera a que todos los pods estén ready antes de considerar el apply exitoso
  wait    = true
  timeout = 300

  # --- Modo de despliegue ---
  # DaemonSet garantiza que Traefik corre en el nodo control-plane de Kind
  # que tiene los puertos 80/443 del contenedor mapeados al host.
  set {
    name  = "deployment.kind"
    value = "DaemonSet"
  }

  # --- Service ---
  # ClusterIP: Kind no tiene LoadBalancer nativo. El tráfico llega
  # directamente por hostPort desde el host.
  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  # --- Puertos HTTP / HTTPS con hostPort ---
  # Enlaza los puertos del contenedor a los del nodo, que Kind ya mapea al host.
  set {
    name  = "ports.web.hostPort"
    value = var.web_host_port
  }
  set {
    name  = "ports.websecure.hostPort"
    value = var.websecure_host_port
  }

  # --- NodeSelector ---
  # Apunta exclusivamente al nodo control-plane etiquetado por el módulo kind.
  # type = "string" evita que Helm auto-castee "true" a booleano, lo que
  # rompe el PodSpec que espera nodeSelector como map[string]string.
  set {
    name  = "nodeSelector.ingress-ready"
    value = "true"
    type  = "string"
  }

  # --- Tolerations ---
  # El control-plane tiene el taint NoSchedule; hay que tolerarlo explícitamente.
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
  # Expone el dashboard vía IngressRoute en http://<dashboard_host>/dashboard/
  # No requiere modificar /etc/hosts porque *.localhost resuelve a 127.0.0.1
  # automáticamente en Linux (nss-myhostname).
  set {
    name  = "ingressRoute.dashboard.enabled"
    value = tostring(var.dashboard_enabled)
  }
  set {
    name  = "ingressRoute.dashboard.matchRule"
    value = "Host(`${var.dashboard_host}`) && (PathPrefix(`/dashboard`) || PathPrefix(`/api`))"
  }
  set {
    name  = "ingressRoute.dashboard.entryPoints[0]"
    value = "web"
  }

  # Logs en formato JSON para facilitar integración futura con herramientas de observabilidad
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

