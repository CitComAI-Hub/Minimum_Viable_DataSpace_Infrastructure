# Creates a database and its owner role in the shared PostgreSQL instance:
#   - the password is generated in Vault (postgres/<name>) and never touches the state
#   - it is synced into the PostgreSQL namespace, for the provisioning Job, and into
#     the service namespace, for the service itself
#   - a Job creates the role and the database idempotently
# Destroying this module does not drop the database, so data is never lost by mistake.

locals {
  username    = coalesce(var.username, var.database)
  secret_name = coalesce(var.secret_name, "${var.name}-postgres-credentials")

  credentials = {
    vault_path       = "postgres/${var.name}"
    static           = { username = local.username }
    generated_fields = ["password"]
  }
}

# Copy in the PostgreSQL namespace, read by the provisioning Job
module "server_credentials" {
  source = "../../vault/consumer"

  name            = "pg-${var.name}"
  namespace       = var.postgres_namespace
  vault_namespace = var.vault_namespace
  vault_address   = var.vault_address

  secrets = {
    "pg-${var.name}" = local.credentials
  }
}

# Copy in the service namespace, read by the service
module "client_credentials" {
  source = "../../vault/consumer"

  name            = "pg-${var.name}-client"
  namespace       = var.namespace
  vault_namespace = var.vault_namespace
  vault_address   = var.vault_address

  secrets = {
    (local.secret_name) = local.credentials
  }
}

resource "kubernetes_job" "provision" {
  metadata {
    name      = "pg-${var.name}"
    namespace = var.postgres_namespace
  }

  wait_for_completion = true

  timeouts {
    create = "5m"
    update = "5m"
  }

  spec {
    backoff_limit = 6

    template {
      metadata {
        labels = { app = "pg-provision", database = var.database }
      }

      spec {
        restart_policy = "Never"

        container {
          name    = "provision"
          image   = var.image
          command = ["sh", "-c"]
          # psql variables (:'user', :"db"...) are quoted by psql, so values are never
          # interpolated into SQL by the shell
          args = [<<-EOT
            set -eu
            until pg_isready -q; do echo "waiting for PostgreSQL"; sleep 2; done
            psql -v ON_ERROR_STOP=1 -v user="$DB_USER" -v password="$DB_PASSWORD" -v db="$DB_NAME" -d postgres <<'SQL'
            SELECT format('CREATE ROLE %I LOGIN', :'user') WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = :'user')\gexec
            ALTER ROLE :"user" WITH LOGIN PASSWORD :'password';
            SELECT format('CREATE DATABASE %I OWNER %I', :'db', :'user') WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = :'db')\gexec
            ALTER DATABASE :"db" OWNER TO :"user";
            REVOKE ALL ON DATABASE :"db" FROM PUBLIC;
            SQL
            # Extensions are created by the superuser, so the owner role needs no extra privileges
            for ext in $DB_EXTENSIONS; do
              echo 'CREATE EXTENSION IF NOT EXISTS :"ext";' | psql -v ON_ERROR_STOP=1 -v ext="$ext" -d "$DB_NAME"
            done
            echo "Database $DB_NAME ready (owner $DB_USER, extensions: $${DB_EXTENSIONS:-none})"
          EOT
          ]

          env {
            name  = "PGHOST"
            value = var.postgres_host
          }
          env {
            name  = "DB_EXTENSIONS"
            value = join(" ", var.extensions)
          }
          env {
            name  = "PGPORT"
            value = tostring(var.postgres_port)
          }
          env {
            name = "PGUSER"
            value_from {
              secret_key_ref {
                name = var.admin_secret_name
                key  = "username"
              }
            }
          }
          env {
            name = "PGPASSWORD"
            value_from {
              secret_key_ref {
                name = var.admin_secret_name
                key  = "password"
              }
            }
          }
          env {
            name  = "DB_NAME"
            value = var.database
          }
          env {
            name = "DB_USER"
            value_from {
              secret_key_ref {
                name = module.server_credentials.secret_names[0]
                key  = "username"
              }
            }
          }
          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = module.server_credentials.secret_names[0]
                key  = "password"
              }
            }
          }
        }
      }
    }
  }
}
