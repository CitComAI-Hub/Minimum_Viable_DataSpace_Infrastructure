# Módulo Terraform: Tailscale Kubernetes Operator

Despliega el **[Tailscale Kubernetes Operator](https://tailscale.com/kb/1236/kubernetes-operator)** y un **ProxyGroup de tipo ingress** que da servicio a todos los Ingress del clúster.

- Cada Ingress de clase `tailscale` anotado con el ProxyGroup se publica como un **Tailscale Service** con su propio dominio (`https://<hostname>.<tu-tailnet>.ts.net`) y su propio certificado TLS.
- En la Tailnet solo aparecen el operador y las réplicas del ProxyGroup (`<prefijo>-0`...), no un dispositivo por servicio. Esto importa con el límite de 50 recursos con tag del plan gratuito.
- Los certificados pueden venir de Let's Encrypt **producción** (de confianza, máximo 5 por hostname y semana) o **staging** (no son de confianza, sin límite práctico), con la variable `letsencrypt_staging`.

## Requisitos en Tailscale

1. **Cliente OAuth** ([Trust credentials](https://login.tailscale.com/admin/settings/oauth)) con los scopes **Devices Core**, **Auth Keys** y **Services** (todos Read & Write) y el tag `tag:k8s-operator`.
2. **MagicDNS** y **HTTPS Certificates** habilitados ([DNS](https://login.tailscale.com/admin/dns)).
3. En la **política de la Tailnet** ([Access controls](https://login.tailscale.com/admin/acls)):

   ```json
   "tagOwners": {
     "tag:k8s-operator": ["autogroup:admin"],
     "tag:k8s":          ["tag:k8s-operator"]
   },
   "autoApprovers": {
     "services": { "tag:k8s": ["tag:k8s"] }
   }
   ```

   El operador lleva `tag:k8s-operator`; los proxies y los servicios, `tag:k8s`. Sin `autoApprovers` los servicios se crean pero no se aprueban y no tienen dirección.

## Uso

```hcl
module "tailscale" {
  source = "../../../modules/tailscale"

  oauth_client_id             = var.tailscale_client_id
  oauth_client_secret         = var.tailscale_client_secret
  operator_hostname           = "mi-cluster-ts-operator"
  proxy_group_hostname_prefix = "mi-cluster-ingress"
  letsencrypt_staging         = true
}
```

## Exponer un servicio

Ingress de clase `tailscale` con las anotaciones del output `ingress_annotations`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mi-servicio
  annotations:
    tailscale.com/proxy-group: ingress
spec:
  ingressClassName: tailscale
  tls:
    - hosts:
        - mi-servicio # nombre en la Tailnet: mi-servicio.<tu-tailnet>.ts.net
  rules:
    - http: # sin host: con ProxyGroup se ignoran las reglas cuyo host no es el FQDN completo
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: mi-servicio
                port:
                  number: 8080
```

Tras el `apply`, un servicio nuevo puede tardar uno o dos minutos en ser accesible mientras Tailscale propaga el Tailscale Service.
