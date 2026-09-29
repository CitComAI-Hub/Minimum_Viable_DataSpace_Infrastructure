# Local Dataspace

Este caso de uso reutiliza el flujo del caso `kind_cluster` y después despliega el Trust Anchor:

1. Ejecuta `use_cases/kind_cluster/Makefile init_apply`, que crea Kind y la plataforma: Tailscale Operator, Vault con External Secrets y PostgreSQL (operador CloudNativePG e instancia `dataspace`).
2. Inicializa Helm/Kubernetes usando `kind_cluster/cluster-config.yaml`.
3. Crea la base de datos `tildb` (usuario `til`) en la instancia `dataspace`, con la contraseña generada en Vault.
4. Instala el Trust Anchor y publica sus APIs TIR y TIL por HTTPS en la Tailnet.

Todos los servicios se exponen con un Ingress de clase `tailscale` servido por el ProxyGroup del clúster: cada uno es un Tailscale Service con su propio dominio y certificado TLS (`https://<hostname>.<tu-tailnet>.ts.net`). Requisitos de la Tailnet: ver [modules/tailscale](../../modules/tailscale/README.md).

## Uso

```bash
make init_apply
```

Para destruirlo en el orden correcto:

```bash
make destroy
```

> **Certificados:** se emiten desde Let's Encrypt producción: son de confianza, pero Let's Encrypt emite como máximo 5 por hostname cada 7 días y cada reconstrucción del clúster pide uno nuevo. Para cambios del día a día usa `terraform apply` sobre el clúster existente. Con `tailscale_letsencrypt_staging = true` (en `kind_cluster/apps`) no hay límite, pero los navegadores bloquean los certificados (`ts.net` usa HSTS) y `curl` necesita `-k`.

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
