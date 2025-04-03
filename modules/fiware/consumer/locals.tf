locals {
  dns_domains = merge(var.services_names, {
    # til = "til"
    # tir = "tir"
  })

  cert_properties = [
    { # did
      id               = local.dns_domains.did
      metadata_name    = "${var.services_names.did}-certificate"
      spec_secret_name = "${var.services_names.did}-tls-secret"
      dns_name         = "${local.dns_domains.did}.${var.service_domain}"
    },
    { # keycloak
      id               = local.dns_domains.keycloak
      metadata_name    = "${var.services_names.keycloak}-certificate"
      spec_secret_name = "${var.services_names.keycloak}-tls-secret"
      dns_name         = "${local.dns_domains.keycloak}.${var.service_domain}"
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

  helm_yaml_path          = "${path.module}/helm"
  helm_yaml_path_provider = "${path.module}/../provider/helm"

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
