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
  name             = local.mongo_service
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
  name             = local.mysql_service
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
      service_name  = local.mysql_service,
      root_password = var.mysql.root_password,
      til_db        = var.mysql.til_db,
      ccs_db        = var.mysql.ccs_db
    })
  ]
}

#? Ingress is needed? did configuration?
resource "helm_release" "walt_id" {
  chart            = var.walt_id.chart_name
  version          = var.walt_id.version
  repository       = var.walt_id.repository
  name             = local.waltid_service
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
      ds_domain = var.ds_domain
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
  name       = local.orionld_service
  namespace  = var.namespace
  wait       = true
  count      = var.flags_deployment.orion_ld ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/orionld.yaml", {
      service_name  = local.mongo_service,
      root_password = var.mongodb.root_password
    })
  ]
}

################################################################################
# Depends on: mysql                                                            #
################################################################################

#? DONE (authorisationRegistry?? & satellite??)
resource "helm_release" "keyrock" {
  depends_on = [helm_release.mysql]

  chart      = var.keyrock.chart_name
  version    = var.keyrock.version
  repository = var.keyrock.repository
  name       = local.keyrock_service
  namespace  = var.namespace
  wait       = true
  count      = var.flags_deployment.keyrock ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP" # LoadBalancer for external access.
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/keyrock.yaml", {
      service_name        = local.keyrock_service,
      ds_domain           = var.ds_domain,
      admin_password      = var.keyrock.admin_password,
      admin_email         = var.keyrock.admin_email
      mysql_root_password = var.mysql.root_password
      mysql_service       = local.mysql_service
    })
  ]
}

#* DONE
resource "helm_release" "credentials_config_service" {
  depends_on = [helm_release.mysql]

  chart      = var.credentials_config_service.chart_name
  version    = var.credentials_config_service.version
  repository = var.credentials_config_service.repository
  name       = local.ccs_service
  namespace  = var.namespace
  wait       = true
  count      = var.flags_deployment.credentials_config_service ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/credentials_config_service.yaml", {
      mysql_service = local.mysql_service,
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
  name       = local.til_service
  namespace  = var.namespace
  wait       = true
  count      = var.flags_deployment.trusted_issuers_list ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/trusted_issuers_list.yaml", {
      service_name  = local.til_service,
      ds_domain     = var.ds_domain,
      mysql_service = local.mysql_service,
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
  name       = local.verifier_service
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
      service_name     = local.verifier_service,
      ds_domain        = var.ds_domain,
      waltid_service   = local.waltid_service,
      tpr_service      = local.tpr_service,
      ccs_service      = local.ccs_service,
      verifier_service = local.verifier_service
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
  depends_on = [helm_release.orion_ld] #, helm_release.dsba_pdp]

  chart      = var.kong.chart_name
  version    = var.kong.version
  repository = var.kong.repository
  name       = local.kong_service
  namespace  = var.namespace
  wait       = true
  count      = var.flags_deployment.kong ? 1 : 0

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/kong.yaml", {
      service_name = local.kong_service,
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
  name       = local.tpr_service
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
      service_name       = local.tpr_service,
      ds_domain          = var.ds_domain,
      orion_service_name = local.orionld_service
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
  name       = local.pdp_service
  namespace  = var.namespace
  wait       = true
  count      = var.flags_deployment.pdp ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/pdp.yaml", {
      verifier_service = local.verifier_service
    })
  ]
}
