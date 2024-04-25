data "template_file" "keycloak_did_config" {
  template = file("${local.helm_config_map_path}/keycloak/did_import.sh")

  vars = {
    waltid_domain = local.dns_dir[local.dns_domains.walt_id]
  }
}

data "template_file" "keycloak_profile" {
  template = file("${local.helm_config_map_path}/keycloak/profile.properties")
}

resource "kubernetes_config_map" "keycloak_did_config" {
  metadata {
    name      = var.keycloak.configmap.did_config
    namespace = var.namespace
  }

  data = {
    "import.sh" = data.template_file.keycloak_did_config.rendered
  }
}

resource "kubernetes_config_map" "keycloak_profile" {
  metadata {
    name      = var.keycloak.configmap.profile
    namespace = var.namespace
  }

  data = {
    "profile.properties" = data.template_file.keycloak_profile.rendered
  }
}
