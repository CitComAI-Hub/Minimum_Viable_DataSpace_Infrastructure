resource "helm_release" "ds_consumer" {
  version          = var.connector.version
  chart            = var.connector.chart_name
  repository       = var.connector.repository
  name             = var.services_names.connector
  namespace        = var.namespace
  create_namespace = true
  wait             = true

  values = [
    yamlencode({
      authentication = {
        generatePasswords = {
          enabled = false
        }
      },
      dataplane = {
        generatePasswords = {
          enabled = false
        }
      },
      dataSpaceConfig            = { enabled = false },
      mysql                      = { enabled = false },
      credentials-config-service = { enabled = false },
      trusted-issuers-list       = { enabled = false },
      vcverifier                 = { enabled = false },
      odrl-pap                   = { enabled = false },
      opa                        = { enabled = false },
      apisix                     = { enabled = false },
      postgis                    = { enabled = false },
      scorpio                    = { enabled = false },
      tm-forum-api               = { enabled = false },
      contract-management        = { enabled = false },
      tpp                        = { enabled = false },
      dss                        = { enabled = false },
      elsi                       = { enabled = false },
      registration               = { enabled = false }
    }),
    # Issuance configuration
    templatefile("${local.helm_yaml_path}/issuance.yaml", {
      services_enabled = var.enable_services,
      # Generate a password for the database connection of trust-anchor
      iss_secret = "issuance-secret",
    }),
    # DID Helper configuration
    templatefile("${local.helm_yaml_path_provider}/did-helper.yaml", {
      services_enabled = var.enable_services,
      ingress_enabled  = var.enable_ingress,
      ingress_class    = var.ingress_class,
      # Generate a password for the database connection of trust-anchor
      iss_secret = "issuance-secret",
      # DID service
      did_host_name  = var.services_names.did,
      did_config     = var.did,
      did_domain     = local.dns_dir[local.dns_domains.did],
      did_secret_tls = local.secrets_tls[local.dns_domains.did],
    }),
    # PostgreSQL configuration
    templatefile("${local.helm_yaml_path_provider}/postgresql-db.yaml", {
      services_enabled = var.enable_services,
      # Generate a password for the database connection of trust-anchor
      iss_secret = "issuance-secret",
      # PostgreSQL configuration
      postgresql_host_name             = var.services_names.postgresql,
      postgresql_config                = var.postgresql,
      postgresql_secrect_key_adminpass = "postgres-admin-password", # not editable
      postgresql_secrect_key_userpass  = "postgres-user-password",  # not editable
      keycloak_config                  = var.keycloak,
      rainbow_config                   = var.rainbow,
    }),
    yamlencode({
      postgresql = {
        primary = {
          initdb = {
            scripts = {
              "create.sh" = <<-EOF
              psql postgresql://${var.postgresql.user_name}:$${POSTGRES_PASSWORD}@localhost:${var.postgresql.port} -c "CREATE DATABASE ${var.keycloak.postgres_db};"
              psql postgresql://${var.postgresql.user_name}:$${POSTGRES_PASSWORD}@localhost:${var.postgresql.port} -c "CREATE DATABASE ${var.rainbow.postgres_db};"
              EOF
            }
          }
        }
      }
    }),
    # Keycloak configuration
    yamlencode({ keycloak = { enabled = false } })

    # templatefile("${local.helm_conf_yaml_path}/connector.yaml", {
    #   ingress_class    = var.ingress_class,
    #   ingress_enabled  = var.enable_ingress,
    #   services_enabled = var.enable_services,
    #   #
    #   til_operator_domain = "${var.trusted_issuers_list_names.operator}.${var.operator_namespace}.svc.cluster.local",
    #   til_provider_domain = "${var.trusted_issuers_list_names.operator}.${var.provider_namespace}.svc.cluster.local",
    #   did_provider_domain = "did-helper.${var.provider_namespace}.svc.cluster.local",
    #   # Keycloak configuration
    #   keycloak_host_name  = var.services_names.keycloak,
    #   keycloak_config     = var.keycloak,
    #   keycloak_domain     = local.dns_dir[local.dns_domains.keycloak],
    #   keycloak_secret_tls = local.secrets_tls[local.dns_domains.keycloak],
    #   # Rainbow configuration
    #   rainbow_host_name  = var.services_names.rainbow,
    #   rainbow_config     = var.rainbow,
    #   rainbow_domain     = local.dns_dir[local.dns_domains.rainbow],
    #   rainbow_secret_tls = local.secrets_tls[local.dns_domains.rainbow]
    # })
  ]
}
