resource "helm_release" "ds_connector" {
  version          = var.connector.version
  chart            = var.connector.chart_name
  repository       = var.connector.repository
  name             = var.services_names.connector
  namespace        = var.namespace
  create_namespace = true
  wait             = true
  timeout          = var.timeout

  values = [
    #* Disabled all services by default
    yamlencode({
      keycloak     = { enabled = var.enable_services.keycloak },
      registration = { enabled = var.enable_services.registration },
      dss          = { enabled = var.enable_services.dss },
      elsi         = { enabled = var.enable_services.elsi },
      #!
      postgresql          = { enabled = false },
      odrl-pap            = { enabled = false },
      opa                 = { enabled = false },
      apisix              = { enabled = false },
      postgis             = { enabled = false },
      scorpio             = { enabled = false },
      tm-forum-api        = { enabled = false },
      contract-management = { enabled = false },
      tpp                 = { enabled = false },
      rainbow             = { enabled = false },
    }),

    ############################################################################
    # Issuance configuration (generate password for keycloak admin)            #
    ############################################################################
    templatefile("${local.helm_fiware_pth}/issuance.yaml", {
      services_enabled = var.enable_services,
      iss_secret       = var.secrets_names.issuance,
    }),

    ############################################################################
    # DID Helper configuration                                                 #
    ############################################################################
    templatefile("${local.helm_fiware_pth}/did-helper.yaml", {
      services_enabled = var.enable_services,
      ingress_enabled  = var.enable_ingress,
      ingress_class    = var.ingress_class,
      # > Issuance secret
      iss_secret = var.secrets_names.issuance,
      # > DID service
      did_host_name  = var.services_names.did, # fullnameOverride not available
      did_config     = var.did,
      did_domain     = local.dns_dir[local.dns_domains.did],
      did_secret_tls = local.secrets_tls[local.dns_domains.did],
    }),
    #* Dataplane
    templatefile("${local.helm_yaml_path}/dataplane.yaml", {
      services_enabled = var.enable_services,
      postgis_config   = var.postgis,
    }),
    #* Data Space Config
    templatefile("${local.helm_yaml_path}/ds-config.yaml", {
      services_enabled = var.enable_services,
      ds_config        = var.dataspace_config,
    }),

    ############################################################################
    # MySQL                                                                    #
    ############################################################################
    #* Secrets creation
    templatefile("${local.helm_fiware_pth}/authentication.yaml", {
      services_enabled = var.enable_services,
      mysql_config     = var.mysql,
    }),
    #* Configuration
    templatefile("${local.helm_fiware_pth}/mysql-db.yaml", {
      services_enabled = var.enable_services,
      mysql_host_name  = var.services_names.mysql,
      mysql_config     = var.mysql,
      initdb_scripts   = <<EOT
      CREATE DATABASE ${var.mysql.db_name_til};
      CREATE DATABASE ${var.mysql.db_name_ccs};
      EOT
    }),

    ############################################################################
    # Credentials Configuration Service                                       #
    ############################################################################
    templatefile("${local.helm_yaml_path}/credentials-config.yaml", {
      services_enabled = var.enable_services,
      ingress_enabled  = var.enable_ingress,
      ingress_class    = var.ingress_class,
      # > CCS configuration
      ccs_host_name = var.services_names.ccs,
      ccs_config    = var.credentials_config_service,
      ccs_domain    = local.dns_dir[local.dns_domains.ccs],
      # > MySQL configuration (secrets generated by: authentication)
      mysql_host_name = var.services_names.mysql,
      mysql_config    = var.mysql,
    }),
    yamlencode({
      credentials-config-service = {
        ingress = {
          tls = var.enable_ingress_tls.ccs ? [
            {
              secretName = local.secrets_tls[local.dns_domains.ccs],
              hosts      = [local.dns_dir[local.dns_domains.ccs]]
            }
          ] : []
        }
      }
    }),
    #* Trusted Issuers List
    templatefile("${local.helm_fiware_pth}/trusted-issuers-list.yaml", {
      services_enabled = var.enable_services,
      # > Ingress configuration
      ingress_enabled = var.enable_ingress,
      ingress_class   = var.ingress_class,
      tls_enabled     = var.enable_ingress_tls,
      # > TIL configuration
      til_host_name  = var.services_names.til,
      til_config     = var.trusted_issuers_list,
      til_domain     = local.dns_dir[local.dns_domains.til],
      til_secret_tls = local.secrets_tls[local.dns_domains.til],
      # > TIR only in the trust anchor
      tir_domain     = null,
      tir_secret_tls = null,
      # MySQL configuration
      mysql_host_name = var.services_names.mysql,
      mysql_config    = var.mysql,
    }),
    #* VCVerifier
    templatefile("${local.helm_yaml_path}/vc-verifier.yaml", {
      services_enabled = var.enable_services,
      ingress_enabled  = var.enable_ingress,
      ingress_class    = var.ingress_class,
      # > VCVerifier configuration
      vcv_host_name  = var.services_names.vcv,
      vcv_config     = var.vcverifier,
      vcv_domain     = local.dns_dir[local.dns_domains.vcv],
      vcv_secret_tls = local.secrets_tls[local.dns_domains.vcv],
      # > TIL
      til_host_name = var.services_names.til,
      # > ccs
      ccs_host_name = var.services_names.ccs,
      ccs_config    = var.credentials_config_service,
      # > DID
      did_host_name = var.services_names.did,
      did_config    = var.did,
    }),
    # templatefile("${local.helm_conf_yaml_path}/connector.yaml", {
    #   ingress_class    = var.ingress_class,
    #   ingress_enabled  = var.enable_ingress,
    #   services_enabled = var.enable_services,
    #   #
    #   til_operator_domain = "trusted-issuers-list.${var.operator_namespace}.svc.cluster.local",
    #   # Data Space Config
    #   ds_config = var.dataspace_config,
    #   ##########################################################################
    #   ## VERIFIERS/CREDENTIAS CONFIGURATION SERVICE                           ##
    #   ##########################################################################
    #   iss_secret = "issuance-secret",
    #   # MySQL configuration (secrets generated by: authentication)
    #   mysql_host_name = var.services_names.mysql,
    #   mysql_config    = var.mysql,
    #   # Credentials Configuration Service
    #   ccs_host_name  = var.services_names.ccs,
    #   ccs_config     = var.credentials_config_service,
    #   ccs_domain     = local.dns_dir[local.dns_domains.ccs],
    #   ccs_secret_tls = local.secrets_tls[local.dns_domains.ccs],
    #   # Trusted Issuers List
    #   til_host_name  = var.services_names.til,
    #   til_config     = var.trusted_issuers_list,
    #   til_domain     = local.dns_dir[local.dns_domains.til],
    #   til_secret_tls = local.secrets_tls[local.dns_domains.til],
    #   # DID service
    #   did_host_name  = var.services_names.did,
    #   did_config     = var.did,
    #   did_domain     = local.dns_dir[local.dns_domains.did],
    #   did_secret_tls = local.secrets_tls[local.dns_domains.did],
    #   # VCVerifier
    #   vcv_host_name  = var.services_names.vcv,
    #   vcv_config     = var.vcverifier,
    #   vcv_domain     = local.dns_dir[local.dns_domains.vcv],
    #   vcv_secret_tls = local.secrets_tls[local.dns_domains.vcv],
    #   ##########################################################################
    #   ## PROXY                                                                ##
    #   ##########################################################################
    #   # PostgreSQL configuration
    #   postgresql_host_name             = var.services_names.postgresql,
    #   postgresql_config                = var.postgresql,
    #   postgresql_secrect_key_adminpass = "postgres-admin-password", # not editable
    #   postgresql_secrect_key_userpass  = "postgres-user-password",  # not editable
    #   # Odrl-pap
    #   odrl_pap_host_name  = var.services_names.pap,
    #   odrl_pap_config     = var.odrl_pap,
    #   odrl_pap_domain     = local.dns_dir[local.dns_domains.pap],
    #   odrl_pap_secret_tls = local.secrets_tls[local.dns_domains.pap],
    #   # Opa
    #   opa_port = 8181,
    #   # APISIX
    #   apisix_host_name               = var.services_names.apisix_service,
    #   apisix_config                  = var.apisix,
    #   apisix_domain                  = local.dns_dir[local.dns_domains.apisix_service],
    #   apisix_secret_tls              = local.secrets_tls[local.dns_domains.apisix_service],
    #   apisix_api_domain              = local.dns_dir[local.dns_domains.apisix_api],
    #   apisix_api_secret_tls          = local.secrets_tls[local.dns_domains.apisix_api],
    #   tpp_rainbow_data_domain        = local.dns_dir[local.dns_domains.tpp_data],
    #   tpp_rainbow_data_secret_tls    = local.secrets_tls[local.dns_domains.tpp_data],
    #   tpp_rainbow_service_domain     = local.dns_dir[local.dns_domains.tpp_service],
    #   tpp_rainbow_service_secret_tls = local.secrets_tls[local.dns_domains.tpp_service],
    #   tpp_rainbow_catalog_domain     = local.dns_dir[local.dns_domains.tpp_catalog],
    #   tpp_rainbow_catalog_secret_tls = local.secrets_tls[local.dns_domains.tpp_catalog],
    #   ##########################################################################
    #   ## BROKER                                                               ##
    #   ##########################################################################
    #   # Postgis
    #   postgis_host_name             = var.services_names.postgis,
    #   postgis_config                = var.postgis,
    #   postgis_secrect_key_adminpass = "postgres-admin-password", # not editable
    #   postgis_secrect_key_userpass  = "postgres-user-password",  # not editable
    #   # Scorpio
    #   scorpio_host_name  = var.services_names.scorpio,
    #   scorpio_config     = var.scorpio,
    #   scorpio_domain     = local.dns_dir[local.dns_domains.scorpio],
    #   scorpio_secret_tls = local.secrets_tls[local.dns_domains.scorpio],
    #   ##########################################################################
    #   ## MARKETPLACE                                                          ##
    #   ##########################################################################
    #   # TMF API
    #   tmf_api_host_name  = var.services_names.tmf_api,
    #   tmf_api_config     = var.tm_forum_api,
    #   tmf_api_domain     = local.dns_dir[local.dns_domains.tmf_api],
    #   tmf_api_secret_tls = local.secrets_tls[local.dns_domains.tmf_api],
    #   # Contract Management
    #   cm_host_name = var.services_names.cm,
    #   cm_config    = var.contract_management,

    #   # Rainbow
    #   rainbow_host_name  = var.services_names.rainbow,
    #   rainbow_config     = var.rainbow,
    #   rainbow_domain     = local.dns_dir[local.dns_domains.rainbow],
    #   rainbow_secret_tls = local.secrets_tls[local.dns_domains.rainbow]
    # })
  ]
}
