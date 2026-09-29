# FIWARE Trust Anchor

Wrapper Terraform para desplegar el chart `trust-anchor` de [FIWARE Data Space Connector 10.9.0](https://github.com/FIWARE/data-space-connector/tree/data-space-connector-10.9.0/charts/trust-anchor).

El módulo:

- Instala el chart remoto y sus dependencias Helm.
- Despliega el Trusted Issuers List (`tir`) con PostgreSQL gestionado por el chart.
- Publica las APIs TIR (`https://tir.<tu-tailnet>.ts.net/v4/issuers`) y TIL (`https://til.<tu-tailnet>.ts.net/issuer`) con un Ingress de clase `tailscale` cada una. Se configuran con `ingress_class_name`, `tir_hostname` y `til_hostname`.
- Expone el endpoint interno como `tir.<namespace>.svc.cluster.local:8080` para los servicios del clúster.

## Uso

```hcl
module "trust_anchor" {
  source = "../../../modules/fiware/trust_anchor"
}
```

Los valores adicionales pueden pasarse mediante `extra_values`.