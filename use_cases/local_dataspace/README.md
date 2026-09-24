# Local Dataspace

Este caso de uso reutiliza el flujo del caso `kind_cluster` y después despliega Keycloak, el portal de onboarding y el Trust Anchor:

1. Ejecuta `use_cases/kind_cluster/Makefile init_apply`, que crea Kind y sus aplicaciones base.
2. Inicializa Helm/Kubernetes usando `kind_cluster/cluster-config.yaml`.
3. El módulo `onboarding_portal` instala en el mismo namespace el chart Data Space Connector 10.8.0, con solo Keycloak y PostgreSQL, y el chart del portal.
4. Instala el Trust Anchor en su namespace separado y conecta el portal con su TIR.

## Uso

```bash
make init_apply
```

Para destruirlo en el orden correcto:

```bash
make destroy
```

Keycloak y el portal comparten el namespace `onboarding`. El Trust Anchor publica el TIR mediante Tailscale en `tir.<tu-tailnet>.ts.net` por defecto.

## Espacio de datos

Peticiones al trust anchor (TIR) desde el clúster:


```bash
curl -X GET "https://tir.<tu-tailnet>.ts.net/v4/issuers" | jq .
```