# FIWARE Onboarding

Portal de onboarding del espacio de datos ([onboarding-citcom](https://github.com/citcomai-hub)) con su Keycloak. Adapta al despliegue local con Tailscale la configuración de referencia en AWS (`fiware-dataspace-on-aws/modules/fiware_dataspace/onboarding`).

El módulo despliega en un namespace existente:

- **Keycloak** (chart Bitnami 25.2.0, imagen `bitnamilegacy/keycloak:26.3.3`) con el realm `onboarding` importado al arrancar, en `https://<keycloak_hostname>.<tailnet>` (por defecto `onboarding-admin`).
- **Portal de onboarding** (chart `onboarding-citcom` 0.1.3) en `https://<onboarding_hostname>.<tailnet>`, que registra en el TIR a los participantes aprobados.
- **Documento del acuerdo** que firman los solicitantes, servido en `https://<onboarding_hostname>.<tailnet>/documents/agreement.pdf` por un nginx mínimo, porque el chart del portal no permite montar ficheros.

## Diferencias con la referencia de AWS

| Referencia (AWS) | Aquí |
|---|---|
| RDS con el usuario maestro para todo | Una base de datos y un usuario propios para Keycloak y otros para el portal (`modules/postgres/database`) |
| Contraseñas con `random_password` (en el state) y la del admin en claro en los values | Generadas en Vault y sincronizadas con External Secrets; el portal las lee de Secrets |
| Secreto del cliente OIDC escrito en el realm por Terraform | El realm contiene `${ONBOARDING_CLIENT_SECRET}` y Keycloak lo sustituye al importar |
| Ingress nginx + cert-manager + external-dns | Ingress de Tailscale (ProxyGroup) con certificado de Let's Encrypt |
| PDF en un bucket S3 público | PDF servido bajo el dominio del portal |
| El pod llega a Keycloak por DNS público | El pod llega a `https://onboarding-admin.<tailnet>.ts.net` por el egress de Tailscale (`modules/tailscale/egress`) |

El último punto es necesario porque el portal usa `openid-client` v6: la URL de descubrimiento tiene que ser HTTPS y coincidir con el *issuer*, que es la URL pública de Keycloak.

## Requisitos

- `modules/tailscale` con egress habilitado (lo está por defecto): ProxyGroup de egress y zona `ts.net` en CoreDNS.
- `modules/vault` y una instancia de `modules/postgres`.
- Los providers `helm`, `kubernetes` y `alekc/kubectl` configurados en el use case.

## Uso

Ver `use_cases/local_dataspace/main.tf`.
