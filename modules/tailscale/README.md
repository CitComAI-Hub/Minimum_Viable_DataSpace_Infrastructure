# Módulo Terraform: Tailscale Kubernetes Operator

Este módulo despliega el **[Tailscale Kubernetes Operator](https://tailscale.com/kb/1236/kubernetes-operator)** en el clúster.

Permite:
- Asignar **nombres de dominio MagicDNS válidos** (`<servicio>.<tu-tailnet>.ts.net`) a cualquier servicio o Ingress de Kubernetes.
- Generar y renovar **certificados TLS/HTTPS de Let's Encrypt válidos automáticamente**.
- Acceder a los servicios desde cualquier máquina de tu Tailnet (WSL, Windows host, portátiles, servidores remotos) **sin editar `/etc/hosts` ni depender de `.localhost`**.

---

## 1. Requisitos previos en Tailscale

1. Inicia sesión en la [Consola de administración de Tailscale](https://login.tailscale.com/admin/settings/oauth).
2. Ve a **Settings** > **OAuth clients** y pulsa **Generate OAuth client**.
3. Asigna los siguientes permisos (**Scopes**):
   - **Devices**: `Read & Write` (para registrar dispositivos en la tailnet)
   - **Auth Keys**: `Read & Write` (para autenticar proxies)
   - **Services**: `Read & Write` (opcional, para gestionar servicios)
4. En **Tags**, asigna el tag `tag:k8s-operator` (asegúrate de que ese tag está definido en tu política ACL de Tailscale si usas ACLs estrictas).
5. Copia el **Client ID** y el **Client Secret**.

---

## 2. Uso del módulo

```hcl
module "tailscale" {
  source = "../../../modules/tailscale"

  oauth_client_id     = var.tailscale_client_id
  oauth_client_secret = var.tailscale_client_secret
}
```

---

## 3. ¿Cómo exponer servicios con dominios y HTTPS automático?

Una vez instalado el operador, tienes dos formas muy sencillas de exponer tus servicios:

### Opción A: Vía Ingress de Kubernetes con IngressClass `tailscale` (Recomendada con HTTPS)

El operador actuará como Ingress Controller, solicitará un certificado Let's Encrypt a Tailscale y servirá HTTPS directamente:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: traefik-dashboard
  namespace: traefik
spec:
  ingressClassName: tailscale
  tls:
    - hosts:
        - traefik # Nombre del nodo en Tailscale
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: traefik
                port:
                  number: 80
```

> **Resultado:** Podrás acceder directamente a `https://traefik.<tu-tailnet>.ts.net/dashboard/` con certificado SSL válido y de confianza en el navegador.

---

### Opción B: Anotando un Service existente

Si tienes un `Service` (por ejemplo, Orion-LD, Keyrock o Traefik), solo añade la anotación `tailscale.com/expose`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: orion-ld
  namespace: fiware
  annotations:
    tailscale.com/expose: "true"
    tailscale.com/hostname: "orion-ld"
spec:
  ports:
    - port: 1026
      targetPort: 1026
      name: http
  selector:
    app: orion-ld
```

El operador creará automáticamente un endpoint en tu tailnet accesible como `http://orion-ld.<tu-tailnet>.ts.net:1026`.
