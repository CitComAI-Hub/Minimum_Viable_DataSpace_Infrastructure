locals {
  mongo_service   = "${var.namespace}-mongodb"
  orionld_service = "${var.namespace}-orion-ld"
  mysql_service   = "${var.namespace}-mysql"
  ccs_service     = "${var.namespace}-cred-conf-service"
  til_service     = "${var.namespace}-trusted-issuers-list"
  keyrock_service = "${var.namespace}-keyrock"
}

#* DONE
resource "helm_release" "mongodb" {
  chart            = var.mongodb.chart_name
  version          = var.mongodb.version
  repository       = var.mongodb.repository
  name             = local.mongo_service
  namespace        = var.namespace
  create_namespace = true

  set {
    name  = "service.type"
    value = "LoadBalancer" # ClusterIP for internal access only.
  }

  values = [<<EOF
        architecture: standalone
        auth:
            enabled: true
            rootPassword: ${var.mongodb.root_password}
        podSecurityContext:
            enabled: false
        containerSecurityContext:
            enabled: false
        resources:
            limits:
            cpu: 200m
            memory: 512Mi
        persistence:
            enabled: true
            size: 8Gi
        EOF
  ]

}

#* DONE
resource "helm_release" "mysql" {
  chart            = var.mysql.chart_name
  version          = var.mysql.version
  repository       = var.mysql.repository
  name             = local.mysql_service
  namespace        = var.namespace
  create_namespace = true

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    <<EOF
        fullnameOverride: ${local.mysql_service}
        auth:
            rootPassword: ${var.mysql.root_password}
        initdbScripts:
            create.sql: |
                CREATE DATABASE ${var.mysql.til_db};
                CREATE DATABASE ${var.mysql.ccs_db};
        EOF
  ]
}

#TODO: test API
resource "helm_release" "orion_ld" {
  chart      = var.orion_ld.chart_name
  version    = var.orion_ld.version
  repository = var.orion_ld.repository
  name       = local.orionld_service
  namespace  = var.namespace

  set {
    name  = "service.type"
    value = "LoadBalancer" # ClusterIP for internal access only.
  }

  values = [<<EOF
        deployment:
            additionalAnnotations:
                prometheus.io/scrape: 'true'
                prometheus.io/port: '8000'
        
        # Configuration for the orion-ld service
        broker:
            db:
                # The db to use. if running in multiservice mode, its used as a prefix.
                # maximum 10 characters!
                name: orion-oper
                auth: 
                    user: root
                    password: ${var.mongodb.root_password}
                    mech: "SCRAM-SHA-1"
                # Configuration of the mongo-db hosts. if multiple hosts are inserted,
                # its assumed that mongo is running as a replica set
                hosts:
                    - ${local.mongo_service}        
        # Configuration for embedding mongodb into the chart. Do not use this in production.
        mongo:
            enabled: false
        EOF
  ]

  depends_on = [helm_release.mongodb]
}

#* DONE
resource "helm_release" "credentials_config_service" {
  chart      = var.credentials_config_service.chart_name
  version    = var.credentials_config_service.version
  repository = var.credentials_config_service.repository
  name       = local.ccs_service
  namespace  = var.namespace

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [<<EOF
        database:
            persistence: true
            host: ${local.mysql_service}
            name: ${var.mysql.ccs_db}
            username: root
            password: ${var.mysql.root_password}
        EOF
  ]

  depends_on = [helm_release.mysql]
}

#? Ingress is needed?
resource "helm_release" "trusted_issuers_list" {
  chart      = var.trusted_issuers_list.chart_name
  version    = var.trusted_issuers_list.version
  repository = var.trusted_issuers_list.repository
  name       = local.til_service
  namespace  = var.namespace

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    <<EOF
        database:
            persistence: true
            host: ${local.mysql_service}
            name: ${var.mysql.til_db}
            username: root
            password: ${var.mysql.root_password}

        # ingress:
        #     til:
        #         enabled: true
        #         annotations:
        #             kubernetes.io/ingress.class: "nginx"
        #             # forcing everything to use ssl
        #             ingress.kubernetes.io/ssl-redirect: "true"
        #             # example annotations, allowing cert-manager to automatically create tls-certs
        #             # kubernetes.io/tls-acme: "true"
        #         hosts:
        #             - host: til.${var.ds_domain}
        #               paths:
        #                 - /
        #         # configure the ingress' tls
        #         # tls:
        #         #     - secretName: til-tls
        #         #       hosts:
        #         #           - til.fiware.org
        #     tir:
        #         enabled: true
        #         annotations:
        #             kubernetes.io/ingress.class: "nginx"
        #             # forcing everything to use ssl
        #             ingress.kubernetes.io/ssl-redirect: "true"
        #             # example annotations, allowing cert-manager to automatically create tls-certs
        #             # kubernetes.io/tls-acme: "true"
        #         hosts:
        #             - host: tir.${var.ds_domain}
        #               paths:
        #                 - /
        #         # configure the ingress' tls
        #         # tls:
        #         #     - secretName: tir-tls
        #         #       hosts:
        #         #           - tir.fiware.org
    EOF
  ]

  depends_on = [helm_release.mysql]
}

# resource "helm_release" "walt_id" {
#     chart       = "vcwaltid"
#     version     = "0.0.17"
#     repository  = "https://i4Trust.github.io/helm-charts"
#     name        = local.waltid_service_name
#     namespace   = module.vars.operator_namespace

#     set {
#         name = "service.type"
#         value = "ClusterIP"
#     }

#     values = [
#         <<EOF

#         EOF
#     ]

#     depends_on = [ null_resource.loadBalancer_installation ]

# }

#? DONE (any other configuration?)
resource "helm_release" "keyrock" {
  chart      = var.keyrock.chart_name
  version    = var.keyrock.version
  repository = var.keyrock.repository
  name       = local.keyrock_service
  namespace  = var.namespace

  set {
    name  = "service.type"
    value = "ClusterIP" # LoadBalancer for external access.
  }

  values = [
    <<EOF
        fullnameOverride: ${local.keyrock_service}

        # Admin keyrock user
        admin:
            user: admin
            password: ${var.keyrock.admin_password}
            email: ${var.keyrock.admin_email}
        
        # MySQL Database configuration
        db:
            user: root
            password: ${var.mysql.root_password}
            host: ${local.mysql_service}
        
        # External hostname of Keyrock
        host: https://keyrock.${var.ds_domain}

        # Port that the keyrock container uses
        port: 8080 # default port

        # Ingress configuration
        ingress:
            enabled: true
            annotations:
                kubernetes.io/ingress.class: "nginx"
                # forcing everything to use ssl
                ingress.kubernetes.io/ssl-redirect: "true"
                # example annotations, allowing cert-manager to automatically create tls-certs
                # kubernetes.io/tls-acme: "true"
            hosts:
              - host: keyrock.${var.ds_domain}
                paths:
                - /
            # configure the ingress' tls
            # tls:
              # - secretName: keyrock-tls
                # hosts:
                  # - keyrock.fiware.org
        
        # ## Configuration of Authorisation Registry (AR)
        # authorisationRegistry:
        #     # -- Enable usage of authorisation registry
        #     enabled: true
        #     # -- Identifier (EORI) of AR
        #     identifier: "did:web:my-did:did"
        #     # -- URL of AR
        #     url: "internal"

        # ## Configuration of iSHARE Satellite
        # satellite:
        #     # -- Enable usage of satellite
        #     enabled: true
        #     # -- Identifier (EORI) of satellite
        #     identifier: "EU.EORI.FIWARESATELLITE"
        #     # -- URL of satellite
        #     url: "https://tir.dataspace.com"
        #     # -- Token endpoint of satellite
        #     tokenEndpoint: "https://https://tir.dataspace.com/token"
        #     # -- Parties endpoint of satellite
        #     partiesEndpoint: "https://https://tir.dataspace.com/parties"

        ## -- Configuration of local key and certificate for validation and generation of tokens
        # token:
        #     # -- Enable storage of local key and certificate
        #     enabled: false

        # # ENV variables for Keyrock
        # additionalEnvVars:
        #     - name: IDM_TITLE
        #     value: "dsba AR"
        #     - name: IDM_DEBUG
        #     value: "true"
        #     - name: DEBUG
        #     value: "*"
        #     - name: IDM_DB_NAME
        #     value: ar_idm
        #     - name: IDM_DB_SEED
        #     value: "true"
        #     - name: IDM_SERVER_MAX_HEADER_SIZE
        #     value: "32768"
        #     - name: IDM_PR_CLIENT_ID
        #     value: "did:web:my-did:did"
        #     - name: IDM_PR_CLIENT_KEY
        #     valueFrom:
        #         secretKeyRef:
        #             name: vcwaltid-tls-sec
        #             key: tls.key
        #     - name: IDM_PR_CLIENT_CRT
        #     valueFrom:
        #         secretKeyRef:
        #             name: vcwaltid-tls-sec
        #             key: tls.crt
    EOF
  ]

  depends_on = [helm_release.mysql]
}
