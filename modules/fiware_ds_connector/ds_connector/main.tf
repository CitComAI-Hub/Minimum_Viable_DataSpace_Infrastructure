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
    templatefile("${local.helm_conf_yaml_path}/connector.yaml", {
      ingress_class    = var.ingress_class,
      ingress_enabled  = var.enable_ingress,
      services_enabled = var.enable_services,
      #
      til_operator_domain = "trusted-issuers-list.ds-operator.svc.cluster.local",
      ##########################################################################
      ## VERIFIERS/CREDENTIAS CONFIGURATION SERVICE                           ##
      ##########################################################################
      iss_secret = "issuance-secret",
      # MySQL configuration (secrets generated by: authentication)
      mysql_host_name = var.services_names.mysql,
      mysql_config    = var.mysql,
      # Credentials Configuration Service
      ccs_host_name = var.services_names.ccs,
      # Trusted Issuers List
      til_host_name  = var.services_names.til,
      til_domain     = local.dns_dir[local.dns_domains.til],
      til_secret_tls = local.secrets_tls[local.dns_domains.til],
      # DID service
      did_host_name  = var.services_names.did,
      did_config     = var.did,
      did_domain     = local.dns_dir[local.dns_domains.did],
      did_secret_tls = local.secrets_tls[local.dns_domains.did],
      # VCVerifier
      vcv_host_name  = var.services_names.vcv,
      vcv_domain     = local.dns_dir[local.dns_domains.vcv],
      vcv_secret_tls = local.secrets_tls[local.dns_domains.vcv],
      ##########################################################################
      ## PROXY                                                                ##
      ##########################################################################
      # PostgreSQL configuration
      postgresql_host_name             = var.services_names.postgresql,
      postgresql_config                = var.postgresql,
      postgresql_secrect_key_adminpass = "postgres-admin-password", # not editable
      postgresql_secrect_key_userpass  = "postgres-user-password",  # not editable
      # Odrl-pap
      odrl_pap_host_name  = var.services_names.pap,
      odrl_pap_domain     = local.dns_dir[local.dns_domains.pap],
      odrl_pap_secret_tls = local.secrets_tls[local.dns_domains.pap],
      # Opa
      opa_port = 8181,
      # APISIX
      apisix_host_name      = var.services_names.apisix_service,
      apisix_domain         = local.dns_dir[local.dns_domains.apisix_service],
      apisix_secret_tls     = local.secrets_tls[local.dns_domains.apisix_service],
      apisix_api_domain     = local.dns_dir[local.dns_domains.apisix_api],
      apisix_api_secret_tls = local.secrets_tls[local.dns_domains.apisix_api],
      ##########################################################################
      ## BROKER                                                               ##
      ##########################################################################
      # Postgis
      postgis_host_name             = var.services_names.postgis,
      postgis_config                = var.postgis,
      postgis_secrect_key_adminpass = "postgres-admin-password", # not editable
      postgis_secrect_key_userpass  = "postgres-user-password",  # not editable
      # Scorpio
      scorpio_enabled    = var.enable_services.scorpio,
      scorpio_host_name  = var.services_names.scorpio,
      scorpio_domain     = local.dns_dir[local.dns_domains.scorpio],
      scorpio_secret_tls = local.secrets_tls[local.dns_domains.scorpio],
      ##########################################################################
      ## MARKETPLACE                                                          ##
      ##########################################################################
      # TMF API
      tmf_api_enabled    = var.enable_services.tmf_api,
      tmf_api_host_name  = var.services_names.tmf_api,
      tmf_api_domain     = local.dns_dir[local.dns_domains.tmf_api],
      tmf_api_secret_tls = local.secrets_tls[local.dns_domains.tmf_api],
      # Contract Management
    })
  ]
}
