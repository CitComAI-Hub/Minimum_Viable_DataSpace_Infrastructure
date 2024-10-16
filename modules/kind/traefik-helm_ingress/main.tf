resource "helm_release" "ingress_traefik" {
  name             = "traefik"
  repository       = "https://helm.traefik.io/traefik"
  chart            = "traefik"
  version          = "31.1.1"
  namespace        = var.namespace
  create_namespace = true
  wait             = true

  values = [<<EOF
    service:
        type: NodePort # or LoadBalancer
    ingressRoute:
        dashboard:
            enabled: true
            entryPoints: 
                - web
    additionalArguments:
        - "--api.insecure=true" # only for demo purposes
    nodeSelector:
        ingress-ready: 'true'
    tolerations:
        - key: node-role.kubernetes.io/master
          operator: Equal
          effect: NoSchedule
        - key: node-role.kubernetes.io/control-plane
          operator: Equal
          effect: NoSchedule
    EOF
  ]
}
