# FIWARE Trust Anchor

Wrapper Terraform para desplegar el chart `trust-anchor` de [FIWARE Data Space Connector 10.9.0](https://github.com/FIWARE/data-space-connector/tree/data-space-connector-10.9.0/charts/trust-anchor).

El módulo:

- Instala el chart remoto y sus dependencias Helm.
- Despliega el Trusted Issuers List (`tir`) contra una base de datos PostgreSQL externa (la instancia compartida de [`modules/postgres`](../../postgres/README.md)). El postgres-operator y la instancia gestionada del chart están desactivados.
- Publica las APIs TIR (`https://tir.<tu-tailnet>.ts.net/v4/issuers`) y TIL (`https://til.<tu-tailnet>.ts.net/issuer`) con un Ingress de clase `tailscale` cada una. Se configuran con `ingress_class_name`, `tir_hostname` y `til_hostname`.
- Expone el endpoint interno como `tir.<namespace>.svc.cluster.local:8080` para los servicios del clúster.

## Uso

```hcl
module "til_database" {
  source = "../../modules/postgres/database"

  name      = "til"
  namespace = "trust-anchor"
  database  = "tildb"
  username  = "til"
}

module "trust_anchor" {
  source = "../../modules/fiware/trust_anchor"

  namespace = "trust-anchor"

  database = {
    host         = module.til_database.host
    port         = module.til_database.port
    name         = module.til_database.database
    username     = module.til_database.username
    secret_name  = module.til_database.secret_name
    password_key = module.til_database.password_key
  }
}
```

Los valores adicionales pueden pasarse mediante `extra_values`.
