# Onboarding Portal

Despliega [SEAMWARE/On-Boarding-Portal](https://github.com/SEAMWARE/On-Boarding-Portal) mediante el chart FIWARE `onboarding-portal` versión `1.4.3`.

El módulo crea:

- Release Helm con imagen `quay.io/seamware/onboarding:0.2.2`.
- Configuración `config` y mapeo de Secrets según los valores oficiales del chart.
- PVC opcional para los archivos subidos.
- Ingress opcional con clase `tailscale` y TLS automático.

El portal requiere una instancia accesible de PostgreSQL, Keycloak, did-helper y el TIR. Sus URLs deben configurarse en `config`, usando los nombres o dominios accesibles desde el clúster.