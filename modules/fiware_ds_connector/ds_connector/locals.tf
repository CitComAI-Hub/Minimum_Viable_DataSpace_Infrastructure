locals {
  # dns_domains = merge(var.services_names, {
  #   til = "til"
  #   tir = "tir"
  # })

  # cert_properties = [
  #   { # til
  #     id               = local.dns_domains.til
  #     metadata_name    = "${var.services_names.til}-certificate"
  #     spec_secret_name = "${var.services_names.til}-tls-secret"
  #     dns_name         = "${local.dns_domains.til}.${var.service_domain}"
  #   },
  #   { # tir
  #     id               = local.dns_domains.tir
  #     metadata_name    = "${var.services_names.tir}-certificate"
  #     spec_secret_name = "${var.services_names.tir}-tls-secret"
  #     dns_name         = "${local.dns_domains.tir}.${var.service_domain}"
  #   }
  # ]

  #!############################################################################
  #! Do not edit below this line                                               #
  #!############################################################################

  # helm_config_map_path = "${path.module}/config/configmaps"
  helm_conf_yaml_path  = "${path.module}/config/helm_values"

  # # services endpoints
  # dns_dir = { for prop in local.cert_properties : prop.id => prop.dns_name if contains(values(local.dns_domains), prop.id) }

  # secrets_tls = { for prop in local.cert_properties : prop.id => prop.spec_secret_name if contains(values(local.dns_domains), prop.id) }

  # cert_properties_map = {
  #   for cert in local.cert_properties : cert.metadata_name => {
  #     spec_secret_name = cert.spec_secret_name
  #     dns_name         = cert.dns_name
  #   }
  # }
}
