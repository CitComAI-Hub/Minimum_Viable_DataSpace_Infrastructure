# Local Dataspace

Este caso de uso reutiliza el flujo del caso `kind_cluster` y después despliega el Trust Anchor:

1. Ejecuta `use_cases/kind_cluster/Makefile init_apply`, que crea Kind y el Tailscale Operator.
2. Inicializa Helm/Kubernetes usando `kind_cluster/cluster-config.yaml`.
3. Instala el Trust Anchor y publica sus APIs TIR y TIL por HTTPS en la Tailnet.

Todos los servicios se exponen con un Ingress de clase `tailscale`: cada uno es un dispositivo de la Tailnet con su propio certificado TLS (`https://<hostname>.<tu-tailnet>.ts.net`).

## Uso

```bash
make init_apply
```

Para destruirlo en el orden correcto:

```bash
make destroy
```

Para ver las URLs completas en los outputs, indica el dominio de tu Tailnet (lo ves en https://login.tailscale.com/admin/dns):

```bash
export TF_VAR_tailnet_domain=tail1234.ts.net
```

## Espacio de datos

Registrar un issuer (TIL) y listar los issuers (TIR) desde cualquier equipo de la Tailnet:

```bash
curl -X POST "https://til.<tu-tailnet>.ts.net/issuer" \
  -H 'Content-Type: application/json' \
  -d '{"did": "did:key:ejemplo", "credentials": []}'

curl "https://tir.<tu-tailnet>.ts.net/v4/issuers" | jq .
```
