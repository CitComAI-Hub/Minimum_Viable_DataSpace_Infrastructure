locals {
  helm_conf_yaml_path = "${path.module}/config/helm_values"
  mongo_service       = "mongodb"
  mysql_service       = "mysql"
  waltid_service      = "waltid"
  orionld_service     = "orion-ld"
  keyrock_service     = "keyrock"
  tpr_service         = "trusted-participants-registry"
  pdp_service         = "pdp"
  kong_service        = "kong"
  ccs_service         = "cred-conf-service"
  til_service         = "trusted-issuers-list"
  verifier_service    = "verifier"
}

#* DONE
resource "helm_release" "mongodb" {
  chart            = var.mongodb.chart_name
  version          = var.mongodb.version
  repository       = var.mongodb.repository
  name             = var.services_names.mongo
  namespace        = var.namespace
  create_namespace = true
  wait             = true
  count            = var.flags_deployment.mongodb ? 1 : 0

  set {
    name  = "service.type"
    value = "LoadBalancer" # ClusterIP for internal access only.
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/mongodb.yaml", {
      root_password = var.mongodb.root_password
    })
  ]
}

#* DONE
resource "helm_release" "mysql" {
  chart            = var.mysql.chart_name
  version          = var.mysql.version
  repository       = var.mysql.repository
  name             = var.services_names.mysql
  namespace        = var.namespace
  create_namespace = true
  wait             = true
  count            = var.flags_deployment.mysql ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/mysql.yaml", {
      service_name  = var.services_names.mysql,
      root_password = var.mysql.root_password,
      til_db        = var.mysql.til_db,
      ccs_db        = var.mysql.ccs_db
    })
  ]
}

#? DONE Ingress is needed? configuration datasource?
resource "helm_release" "walt_id" {
  depends_on = [kubernetes_manifest.certs_creation]

  chart            = var.walt_id.chart_name
  version          = var.walt_id.version
  repository       = var.walt_id.repository
  name             = var.services_names.walt_id
  namespace        = var.namespace
  create_namespace = true
  wait             = true
  count            = var.flags_deployment.walt_id ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/waltid.yaml", {
      dns_names       = local.dns_dir[var.services_names.walt_id],
      secret_tls_name = local.secrets_tls[var.services_names.walt_id],
    })
  ]
}

################################################################################
# Depends on: mongodb                                                          #
################################################################################

#* DONE
resource "helm_release" "orion_ld" {
  depends_on = [helm_release.mongodb]

  chart      = var.orion_ld.chart_name
  version    = var.orion_ld.version
  repository = var.orion_ld.repository
  name       = var.services_names.orion_ld
  namespace  = var.namespace
  wait       = true
  count      = var.flags_deployment.orion_ld ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/orionld.yaml", {
      service_name  = var.services_names.mongo,
      root_password = var.mongodb.root_password,
      orion_db_name = "orion-oper" #! maximum 10 characters
    })
  ]
}

################################################################################
# Depends on: mysql                                                            #
################################################################################

#? DONE
resource "helm_release" "keyrock" {
  depends_on = [helm_release.mysql, kubernetes_manifest.certs_creation]

  chart      = var.keyrock.chart_name
  version    = var.keyrock.version
  repository = var.keyrock.repository
  name       = var.services_names.keyrock
  namespace  = var.namespace
  wait       = true
  count      = var.flags_deployment.keyrock ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP" # LoadBalancer for external access.
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/keyrock.yaml", {
      service_name        = var.services_names.keyrock,
      dns_names           = local.dns_dir[var.services_names.keyrock],
      secret_tls_name     = local.secrets_tls[var.services_names.keyrock],
      waltid_secret_tls   = local.secrets_tls[var.services_names.walt_id],
      admin_password      = var.keyrock.admin_password,
      admin_email         = var.keyrock.admin_email,
      mysql_root_password = var.mysql.root_password,
      mysql_service       = var.services_names.mysql
    })
  ]
}

#* DONE
resource "helm_release" "credentials_config_service" {
  depends_on = [helm_release.mysql]

  chart      = var.credentials_config_service.chart_name
  version    = var.credentials_config_service.version
  repository = var.credentials_config_service.repository
  name       = var.services_names.ccs
  namespace  = var.namespace
  wait       = true
  count      = var.flags_deployment.credentials_config_service ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/credentials_config_service.yaml", {
      mysql_service = var.services_names.mysql,
      ccs_db        = var.mysql.ccs_db,
      root_password = var.mysql.root_password
    })
  ]
}

#? Ingress is needed? Ingress is configured for the Trusted Issuers List and Trusted Participant List??
resource "helm_release" "trusted_issuers_list" {
  depends_on = [helm_release.mysql]

  chart      = var.trusted_issuers_list.chart_name
  version    = var.trusted_issuers_list.version
  repository = var.trusted_issuers_list.repository
  name       = var.services_names.til
  namespace  = var.namespace
  wait       = true
  count      = var.flags_deployment.trusted_issuers_list ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/trusted_issuers_list.yaml", {
      service_name  = var.services_names.til,
      ds_domain     = var.ds_domain,
      mysql_service = var.services_names.mysql,
      til_db        = var.mysql.til_db,
      root_password = var.mysql.root_password
    })
  ]
}

################################################################################
# Depends on: walt_id, credentials_config_service, trusted_issuers_list        #
################################################################################

#? Ingress is needed? certificates configuration?
resource "helm_release" "verifier" {
  depends_on = [helm_release.credentials_config_service, helm_release.walt_id, helm_release.trusted_issuers_list]

  chart      = var.verifier.chart_name
  version    = var.verifier.version
  repository = var.verifier.repository
  name       = var.services_names.verifier
  namespace  = var.namespace
  wait       = true
  count      = var.flags_deployment.verifier ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/verifier.yaml", {
      namespace        = var.namespace,
      service_name     = var.services_names.verifier,
      ds_domain        = var.ds_domain,
      waltid_service   = var.services_names.walt_id,
      tpr_service      = var.services_names.tpr,
      ccs_service      = var.services_names.ccs,
      verifier_service = var.services_names.verifier
    })
  ]
}

################################################################################
# Depends on: orion_ld                                                         #
################################################################################

#? Where are the Orion and PDP services referred to?
#FIXME: Error deployment!!
# Defaulted container "proxy" out of: proxy, clear-stale-pid (init)
# Error from server (BadRequest): container "proxy" in pod "ds-operator-kong-kong-67fc695f5d-pfgkv" is waiting to start: PodInitializing
resource "helm_release" "kong" {
  depends_on = [helm_release.orion_ld, kubernetes_manifest.certs_creation] #, helm_release.pdp

  chart      = var.kong.chart_name
  version    = var.kong.version
  repository = var.kong.repository
  name       = var.services_names.kong
  namespace  = var.namespace
  wait       = true
  count      = var.flags_deployment.kong ? 1 : 0

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/kong_conf.yaml", {
      service_name = var.services_names.kong,
      ds_domain    = var.ds_domain
    })
  ]
}

#? SATELLITE ???
resource "helm_release" "trusted_participants_registry" {
  depends_on = [helm_release.orion_ld]

  chart      = var.trusted_participants_registry.chart_name
  version    = var.trusted_participants_registry.version
  repository = var.trusted_participants_registry.repository
  name       = var.services_names.tpr
  namespace  = var.namespace
  wait       = true
  count      = var.flags_deployment.trusted_participants_registry ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP"
  }
  set {
    name  = "service.port"
    value = 8080
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/trusted_participants_registry.yaml", {
      service_name       = var.services_names.tpr,
      ds_domain          = var.ds_domain,
      orion_service_name = var.services_names.orion_ld
    })
  ]
}

################################################################################
# Depends on: keyrock, verifier                                                #
################################################################################

#FIXME: Error deployment!!
# {"level":"warning","msg":"Invalid LOG_REQUESTS configured, will enable request logging by default. Err: strconv.ParseBool: parsing \"\": invalid syntax.","time":"2024-02-14T13:33:46Z"}
# {"level":"warning","msg":"Issuer repository is kept in-memory. No persistence will be applied, do NEVER use this for anything but development or testing!","time":"2024-02-14T13:33:46Z"}
# {"level":"info","msg":"iShare is enabled.","time":"2024-02-14T13:33:46Z"}
# {"level":"info","msg":"Will use the delegtion address https://ar.isharetest.net/delegation.","time":"2024-02-14T13:33:46Z"}
# {"level":"info","msg":"Will use the token address https://ar.isharetest.net/connect/token.","time":"2024-02-14T13:33:46Z"}
# {"level":"warning","msg":"Was not able to parse the key . err: Invalid Key: Key must be a PEM encoded PKCS1 or PKCS8 key","time":"2024-02-14T13:33:46Z"}
# {"level":"fatal","msg":"Was not able to read the rsa private key from /iShare/key.pem, err: Invalid Key: Key must be a PEM encoded PKCS1 or PKCS8 key","time":"2024-02-14T13:33:46Z"}
resource "helm_release" "pdp" {
  depends_on = [helm_release.keyrock, helm_release.verifier]

  chart      = var.pdp.chart_name
  version    = var.pdp.version
  repository = var.pdp.repository
  name       = var.services_names.pdp
  namespace  = var.namespace
  wait       = true
  count      = var.flags_deployment.pdp ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/pdp.yaml", {
      verifier_service = var.services_names.verifier
    })
  ]
}
