# PostgreSQL

PostgreSQL instances managed by [CloudNativePG](https://cloudnative-pg.io), deployed with its Helm charts. Services do not deploy their own instance: each one requests a database and an owner role in a shared instance.

Requires [`modules/vault`](../vault/README.md): every password is generated in Vault and synced with External Secrets, so none of them ends up in the Terraform state.

## Modules

| Module | What it deploys |
|---|---|
| `operator/` | The CloudNativePG operator (`cloudnative-pg` chart). Once per cluster. |
| `.` (this one) | One PostgreSQL instance (`cluster` chart), of type `postgresql` or `postgis`. Call it once per instance. |
| `database/` | A database and its owner role in an instance, for one service. |

## Instances

```hcl
module "postgres_operator" {
  source = "../../modules/postgres/operator"
}

# Configuration of the data space services
module "dataspace_postgres" {
  source = "../../modules/postgres"

  name      = "dataspace"
  namespace = "databases" # must already exist
  type      = "postgresql"

  depends_on = [module.postgres_operator]
}

# Data broker, kept apart from the data space configuration
module "broker_postgres" {
  source = "../../modules/postgres"

  name      = "broker"
  namespace = "databases"
  type      = "postgis"

  depends_on = [module.postgres_operator]
}
```

Each instance gets:

- The read-write Service `<name>-rw.<namespace>.svc.cluster.local:5432` (plus `-ro` and `-r`).
- Superuser credentials generated in Vault (`postgres/<name>/superuser`), synced only into the instance namespace as the `<name>-superuser` Secret.

Applying the module waits until the instance accepts connections.

## Requesting a database for a service

```hcl
module "til_database" {
  source = "../../modules/postgres/database"

  name      = "til"          # unique in the cluster
  namespace = "trust-anchor" # service namespace, must already exist
  database  = "tildb"
  username  = "til"

  # Defaults point to the "dataspace" instance; for another one:
  # postgres_namespace = module.broker_postgres.namespace
  # postgres_host      = module.broker_postgres.host
  # admin_secret_name  = module.broker_postgres.admin_secret_name
  # extensions         = ["postgis"]
}
```

The submodule:

1. Generates the password in Vault (`postgres/<name>`).
2. Syncs it into the instance namespace (`pg-<name>` Secret) and into the service namespace (`<name>-postgres-credentials` Secret, keys `username` and `password`).
3. Runs a Job that creates the role and the database idempotently, owned by that role, revokes access for everyone else and creates the requested `extensions` as superuser.

Its outputs (`host`, `port`, `database`, `username`, `secret_name`, `password_key`) only become available once the database exists and the Secret is in place, so a Helm release that uses them never starts before its database is ready.

Destroying the submodule keeps the database and its data; drop it manually if it is no longer needed.

The use case needs the `helm`, `kubernetes` and `alekc/kubectl` providers configured with the cluster kubeconfig.
