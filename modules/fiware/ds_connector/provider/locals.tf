locals {
  dns_domains = merge(var.services_names, {
    til = "til"
    # tir = "tir"
  })

  cert_properties = [
    { # ccs
      id               = local.dns_domains.ccs
      metadata_name    = "${var.services_names.ccs}-certificate"
      spec_secret_name = "${var.services_names.ccs}-tls-secret"
      dns_name         = "${local.dns_domains.ccs}.${var.service_domain}"
    },
    { # til
      id               = local.dns_domains.til
      metadata_name    = "${var.services_names.til}-certificate"
      spec_secret_name = "${var.services_names.til}-tls-secret"
      dns_name         = "${local.dns_domains.til}.${var.service_domain}"
    },
    { # did
      id               = local.dns_domains.did
      metadata_name    = "${var.services_names.did}-certificate"
      spec_secret_name = "${var.services_names.did}-tls-secret"
      dns_name         = "${local.dns_domains.did}.${var.service_domain}"
    },
    { # vcv
      id               = local.dns_domains.vcv
      metadata_name    = "${var.services_names.vcv}-certificate"
      spec_secret_name = "${var.services_names.vcv}-tls-secret"
      dns_name         = "${local.dns_domains.vcv}.${var.service_domain}"
    },
    { # pap
      id               = local.dns_domains.pap
      metadata_name    = "${var.services_names.pap}-certificate"
      spec_secret_name = "${var.services_names.pap}-tls-secret"
      dns_name         = "${local.dns_domains.pap}.${var.service_domain}"
    },
    ############################################################################
    # APISIX
    { # - apisix-service
      id               = local.dns_domains.apisix_service
      metadata_name    = "${var.services_names.apisix_service}-certificate"
      spec_secret_name = "${var.services_names.apisix_service}-tls-secret"
      dns_name         = "${local.dns_domains.apisix_service}.${var.service_domain}"
    },
    { # - apisix-api
      id               = local.dns_domains.apisix_api
      metadata_name    = "${var.services_names.apisix_api}-certificate"
      spec_secret_name = "${var.services_names.apisix_api}-tls-secret"
      dns_name         = "${local.dns_domains.apisix_api}.${var.service_domain}"
    },
    { # - tpp_data_service
      id               = local.dns_domains.tpp_data
      metadata_name    = "${var.services_names.tpp_data}-certificate"
      spec_secret_name = "${var.services_names.tpp_data}-tls-secret"
      dns_name         = "${local.dns_domains.tpp_data}.${var.service_domain}"
    },
    { # - tpp_service
      id               = local.dns_domains.tpp_service
      metadata_name    = "${var.services_names.tpp_service}-certificate"
      spec_secret_name = "${var.services_names.tpp_service}-tls-secret"
      dns_name         = "${local.dns_domains.tpp_service}.${var.service_domain}"
    },
    { # - tpp_catalog
      id               = local.dns_domains.tpp_catalog
      metadata_name    = "${var.services_names.tpp_catalog}-certificate"
      spec_secret_name = "${var.services_names.tpp_catalog}-tls-secret"
      dns_name         = "${local.dns_domains.tpp_catalog}.${var.service_domain}"
    },
    ############################################################################
    { # scorpio
      id               = local.dns_domains.scorpio
      metadata_name    = "${var.services_names.scorpio}-certificate"
      spec_secret_name = "${var.services_names.scorpio}-tls-secret"
      dns_name         = "${local.dns_domains.scorpio}.${var.service_domain}"
    },
    { # tmf-api
      id               = local.dns_domains.tmf_api
      metadata_name    = "${var.services_names.tmf_api}-certificate"
      spec_secret_name = "${var.services_names.tmf_api}-tls-secret"
      dns_name         = "${local.dns_domains.tmf_api}.${var.service_domain}"
    },
    { # rainbow
      id               = local.dns_domains.rainbow
      metadata_name    = "${var.services_names.rainbow}-certificate"
      spec_secret_name = "${var.services_names.rainbow}-tls-secret"
      dns_name         = "${local.dns_domains.rainbow}.${var.service_domain}"
    },
  ]

  #!############################################################################
  #! Do not edit below this line                                               #
  #!############################################################################

  helm_yaml_path = "${path.module}/helm"

  # services endpoints
  dns_dir = { for prop in local.cert_properties : prop.id => prop.dns_name if contains(values(local.dns_domains), prop.id) }

  secrets_tls = { for prop in local.cert_properties : prop.id => prop.spec_secret_name if contains(values(local.dns_domains), prop.id) }

  cert_properties_map = {
    for cert in local.cert_properties : cert.metadata_name => {
      spec_secret_name = cert.spec_secret_name
      dns_name         = cert.dns_name
    }
  }
}
