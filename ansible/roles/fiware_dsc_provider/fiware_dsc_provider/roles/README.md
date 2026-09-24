## 📁 `tasks/`
**Contenido:** Aquí van las tareas que ejecuta el rol.

**Archivo principal:** `main.yml`

**Ejemplo:**
```yaml
- name: Instalar Helm si no está presente
  include_role:
    name: helm

- name: Desplegar Data Space Connector con Helm
  helm:
    name: data-space-connector
    chart: "{{ chart_path }}"
    namespace: "{{ namespace }}"
    values: "{{ helm_values }}"
```

> Aquí defines el flujo de ejecución del rol. Puedes dividirlo en varios archivos y usar `include_tasks`.

---

## 📁 `templates/`
**Contenido:** Plantillas Jinja2 que se renderizan dinámicamente.

**Ejemplo de uso:** Si necesitas generar un `values.yaml` para Helm con variables dinámicas, lo pondrías aquí como `values.yaml.j2`.

```yaml
replicaCount: {{ replica_count }}
image:
  repository: {{ image_repo }}
  tag: {{ image_tag }}
```

> Luego lo puedes usar en una tarea con el módulo `template`.

---

## 📁 `defaults/`
**Contenido:** Variables con valores por defecto que pueden ser sobrescritos.

**Archivo principal:** `main.yml`

**Ejemplo:**
```yaml
namespace: "data-space"
chart_path: "charts/data-space-connector"
replica_count: 2
```

> Estas son las variables que quieres que tengan un valor base pero que puedan ser modificadas por el usuario del rol.

---

## 📁 `vars/`
**Contenido:** Variables que no deberían ser sobrescritas fácilmente.

**Archivo principal:** `main.yml`

**Ejemplo:**
```yaml
helm_values:
  replicaCount: "{{ replica_count }}"
  image:
    repository: "{{ image_repo }}"
    tag: "{{ image_tag }}"
```

> Se usan para definir valores internos del rol que no se espera que el usuario cambie.

---

## 📁 `meta/`
**Contenido:** Metadatos del rol, como dependencias.

**Archivo principal:** `main.yml`

**Ejemplo:**
```yaml
galaxy_info:
  author: Sergio
  description: Rol para desplegar el Data Space Connector con Helm
  license: MIT
  min_ansible_version: 2.9
  platforms:
    - name: Kubernetes
      versions:
        - all

dependencies: []
```

> Esto es útil si vas a publicar el rol en Galaxy o compartirlo con otros equipos.

---

## 📁 `files/`
**Contenido:** Archivos estáticos que se copian tal cual.

**Ejemplo:** Si tienes un `values.yaml` fijo o un script de instalación personalizado, lo pondrías aquí.

> Se usan con el módulo `copy` o `unarchive`.

---

¿Quieres que te ayude a escribir un ejemplo completo de `main.yml` para el rol o montar un `values.yaml.j2` para Helm? Podemos dejarlo listo para producción.