# Local Dataspace

Este caso de uso reutiliza el flujo del caso `kind_cluster` y después despliega el Trust Anchor:

1. Ejecuta `use_cases/kind_cluster/Makefile init_apply`, que crea Kind y sus aplicaciones base.
2. Inicializa Helm/Kubernetes usando `kind_cluster/cluster-config.yaml` y despliega el Trust Anchor FIWARE desde el `main.tf` principal.

## Uso

```bash
make init_apply
```

Para destruirlo en el orden correcto:

```bash
make destroy
```

El Trust Anchor publica el TIR mediante Tailscale en `tir.<tu-tailnet>.ts.net` por defecto. El chart FIWARE se obtiene desde `https://fiware.github.io/data-space-connector/`.

## Espacio de datos

Peticiones al trust anchor (TIR) desde el clúster:


```bash
curl -X GET "https://tir.<tu-tailnet>.ts.net/v4/issuers" | jq .
```