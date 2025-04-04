resource "helm_release" "ds_consumer" {
  version          = var.connector.version
  chart            = var.connector.chart_name
  repository       = var.connector.repository
  name             = var.services_names.connector
  namespace        = var.namespace
  create_namespace = true
  wait             = true

  values = [
    #* Disabled all services by default
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
      dataSpaceConfig            = { enabled = var.enable_services.dsconfig },
      mysql                      = { enabled = var.enable_services.mysql },
      credentials-config-service = { enabled = var.enable_services.ccs },
      trusted-issuers-list       = { enabled = var.enable_services.til },
      vcverifier                 = { enabled = var.enable_services.vcv },
      odrl-pap                   = { enabled = var.enable_services.pap },
      opa                        = { enabled = var.enable_services.opa },
      apisix                     = { enabled = var.enable_services.apisix },
      postgis                    = { enabled = var.enable_services.postgis },
      scorpio                    = { enabled = var.enable_services.scorpio },
      tm-forum-api               = { enabled = var.enable_services.tmf_api },
      contract-management        = { enabled = var.enable_services.cm },
      tpp                        = { enabled = var.enable_services.tpp },
      dss                        = { enabled = var.enable_services.dss },
      elsi                       = { enabled = var.enable_services.elsi },
      registration               = { enabled = var.enable_services.registration },
    }),
    #* Issuance configuration (generate password for keycloak admin)
    templatefile("${local.helm_yaml_path_provider}/issuance.yaml", {
      services_enabled = var.enable_services,
      iss_secret       = var.secrets_names.issuance,
    }),
    #* DID Helper configuration
    templatefile("${local.helm_yaml_path_provider}/did-helper.yaml", {
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
    #* PostgreSQL configuration
    templatefile("${local.helm_yaml_path_provider}/postgresql-db.yaml", {
      services_enabled = var.enable_services,
      # > PostgreSQL configuration
      postgresql_host_name             = var.services_names.postgresql,
      postgresql_config                = var.postgresql,
      postgresql_secrect_key_adminpass = "postgres-admin-password", # not editable
      postgresql_secrect_key_userpass  = "postgres-user-password",  # not editable
    }),
    yamlencode({ # - specific databases for consumer
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
    #* Keycloak configuration
    templatefile("${local.helm_yaml_path}/keycloak.yaml", {
      services_enabled = var.enable_services,
      ingress_class    = var.ingress_class,
      ingress_enabled  = var.enable_ingress,
      # > Issuance secret
      iss_secret = var.secrets_names.issuance,
      # > DID service
      did_host_name = var.services_names.did,
      # PostgreSQL configuration
      postgresql_host_name             = var.services_names.postgresql,
      postgresql_config                = var.postgresql,
      postgresql_secrect_key_adminpass = var.postgresql_secrets_noedit.key_adminpass,
      # > Keycloak configuration
      keycloak_host_name  = var.services_names.keycloak,
      keycloak_config     = var.keycloak,
      keycloak_domain     = local.dns_dir[local.dns_domains.keycloak],
      keycloak_secret_tls = local.secrets_tls[local.dns_domains.keycloak],
    }),
    #* Rainbow configuration
    templatefile("${local.helm_yaml_path_provider}/rainbow.yaml", {
      services_enabled = var.enable_services,
      ingress_class    = var.ingress_class,
      ingress_enabled  = var.enable_ingress,
      # > PostgreSQL configuration
      postgresql_host_name             = var.services_names.postgresql,
      postgresql_config                = var.postgresql,
      postgresql_secrect_key_adminpass = var.postgresql_secrets_noedit.key_adminpass,
      # > Rainbow configuration
      rainbow_host_name = var.services_names.rainbow,
      rainbow_config    = var.rainbow,
      rainbow_domain    = local.dns_dir[local.dns_domains.rainbow],
    }),
  ]
}
