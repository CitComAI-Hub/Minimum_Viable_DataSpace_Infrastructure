# FIWARE Trust Anchor

Wrapper Terraform para desplegar el chart `trust-anchor` de [FIWARE Data Space Connector 10.9.0](https://github.com/FIWARE/data-space-connector/tree/data-space-connector-10.9.0/charts/trust-anchor).

El módulo:

- Instala el chart remoto y sus dependencias Helm.
- Despliega el Trusted Issuers List (`tir`) con PostgreSQL gestionado por el chart.
- Publica el endpoint TIR mediante un Ingress de Tailscale (`https://tir.<tu-tailnet>.ts.net`) por defecto.
- Expone el endpoint interno como `tir.<namespace>.svc.cluster.local:8080` para los servicios del clúster.

## Uso

```hcl
module "trust_anchor" {
  source = "../../../modules/fiware/trust_anchor"
}
```

Los valores adicionales pueden pasarse mediante `extra_values`.