locals {
  dns_domains = merge(var.services_names, {
    til = "til"
    # tir = "tir"
  })

  cert_properties = [
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
    }
  ]

  #!############################################################################
  #! Do not edit below this line                                               #
  #!############################################################################

  # helm_config_map_path = "${path.module}/config/configmaps"
  helm_conf_yaml_path = "${path.module}/config/helm_values"

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
