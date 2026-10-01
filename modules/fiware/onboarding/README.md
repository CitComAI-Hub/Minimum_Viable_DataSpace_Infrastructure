# FIWARE Onboarding

Portal de onboarding del espacio de datos ([onboarding-citcom](https://github.com/citcomai-hub), fork con otro aspecto gráfico del [On-Boarding-Portal de SEAMWARE](https://github.com/SEAMWARE/On-Boarding-Portal) 0.2.2) con su Keycloak y su did-helper. Adapta al despliegue local con Tailscale la configuración de referencia en AWS (`fiware-dataspace-on-aws/modules/fiware_dataspace/onboarding`).

## Componentes

El módulo despliega en un namespace existente (`onboarding` en `use_cases/local_dataspace`):

| Componente | Origen | URL en la Tailnet |
|---|---|---|
| **Portal de onboarding** | Chart `onboarding-citcom` 1.1.0 | `https://<onboarding_hostname>.<tailnet>` (por defecto `onboarding`) |
| **Keycloak 26.7.4** | Chart del [FIWARE Data Space Connector](https://github.com/FIWARE/data-space-connector/tree/data-space-connector-10.10.1) 10.10.1 | `https://<keycloak_hostname>.<tailnet>` (por defecto `onboarding-admin`) |
| **did-helper 0.6.0** | Chart del Data Space Connector 10.10.1 | `https://<did_hostname>.<tailnet>` (por defecto `onboarding-did`) |
| **Documento del acuerdo** | nginx mínimo | `https://<onboarding_hostname>.<tailnet>/documents/agreement.pdf` |

Keycloak y el did-helper salen de una sola release de Helm (`onboarding-dsc`) del chart del connector con todos sus demás componentes desactivados.

## Por qué está montado así

### Keycloak del chart del Data Space Connector

- La plantilla con la que el portal crea el realm de cada participante (imagen 1.1) usa el **modelo OID4VCI de Keycloak 26.4+**: un ámbito de cliente con `protocol: oid4vc` por credencial. Keycloak 26.3 lo ignora sin dar error y el realm queda sin credenciales emitibles.
- Bitnami solo publica imágenes gratuitas en `bitnamilegacy`, congeladas en Keycloak 26.3.3. El chart del connector despliega la **imagen oficial 26.7.4**, ya con las características OID4VC activadas (`oid4vc-vci`, `oid4vc-vci-preauth-code`, `oid4vc-vci-rest-credential-offer`).
- Del chart del connector solo se usa Keycloak. Se desactivan `decentralizedIam`, `scorpio`, `tm-forum-api`, `contract-management` y `fdsc-edc`, que vienen activos por defecto, y también la generación de contraseñas de `issuance`.
- El connector importa su propio realm de ejemplo (`test-realm`) cuando `keycloak.realm.import` está activo. Se desactiva, se monta el realm `onboarding` (`resources/keycloak-realm-onboarding.json`) y se pide `--import-realm` como argumento extra.
- El administrador (`keycloak-admin`) sale del Secret `keycloak-admin`, generado en Vault. La base de datos es `keycloak`, en la instancia PostgreSQL compartida, con usuario propio.
- El chart añade dos piezas suyas inofensivas: un ConfigMap `ca-certs-script` y un Secret `dsc-keycloak-env` vacío.

### did-helper del chart del Data Space Connector

- Resuelve los DIDs `did:web` que el portal genera para cada participante (ver [Onboarding de un participante](#onboarding-de-un-participante)). Se configura en **modo Keycloak**: construye cada documento DID al vuelo a partir de las claves públicas (JWKS) del realm.
- El subchart `did-helper` del connector convierte cada clave de `config.server` en una variable de entorno, así que admite ese modo con `didType: keycloak` y `keycloakHost` (la URL interna de Keycloak). No genera claves propias (`generateKey.enabled: false`).
- Detalles de la versión 0.6.0 que su documentación no recoge:
  - `OUTPUT_FORMAT=none`, que recomienda el README del portal, ya no existe.
  - `OUTPUT_FILE` tiene que estar vacío. Si no, el did-helper escribe un fichero y termina sin arrancar el servidor (la imagen lo trae definido; el chart lo vacía).
  - El realm va tal cual en la ruta, no en base64.
- El identificador del documento DID se construye con la cabecera `Host` de la petición, y Tailscale la reenvía bien: el `id` coincide con el DID generado.
- El did-helper **tiene que ser accesible en su hostname de la Tailnet**: `did:web` solo se resuelve con HTTPS en el host que aparece en el DID. Lo usan los verificadores (por ejemplo el VCVerifier de un connector) y los wallets. Los pods del propio clúster tendrán que llegar a él por el egress de Tailscale (`modules/tailscale/egress`).

### Resto de decisiones

- **Ingress propios en lugar de los de los charts:** con la clase `tailscale` y un ProxyGroup, las reglas tienen que ir sin `host` (el nombre sale de `tls.hosts`), y los charts ponen host.
- **Egress hacia Keycloak:** el portal usa `openid-client` v6, que exige que la URL de descubrimiento sea HTTPS y coincida con el *issuer*, es decir, la URL pública de Keycloak. El pod del portal la alcanza por el egress de Tailscale.
- **PDF con nginx:** el chart del portal no permite montar ficheros, así que un nginx mínimo sirve `/documents` bajo el dominio del portal.
- **Administrador del portal:** el realm `onboarding` se importa sin usuarios. Un Job crea el usuario `admin` con la contraseña generada en Vault, usando la API de administración de Keycloak, y funciona también sobre un realm ya importado.

## Accesos

| Para qué | URL | Usuario | Contraseña |
|---|---|---|---|
| Administración del portal (aprobar solicitudes) | `https://onboarding.<tailnet>` | `admin` | Vault `onboarding/portal-admin` |
| Consola de Keycloak (todos los realms) | `https://onboarding-admin.<tailnet>/admin/` | `keycloak-admin` | Vault `onboarding/keycloak-admin` |

Las contraseñas también se obtienen del clúster:

```bash
kubectl -n onboarding get secret portal-admin   -o jsonpath='{.data.password}' | base64 -d
kubectl -n onboarding get secret keycloak-admin -o jsonpath='{.data.password}' | base64 -d
```

Todos los usuarios del realm `onboarding` son administradores del portal, porque el portal no comprueba roles. Ese realm solo debe contener cuentas de administración.

## Onboarding de un participante

Con `did_creation_enabled = true` (por defecto) los solicitantes se registran **sin DID**.

### 1. Registro

El solicitante rellena el formulario del portal, que no pide DID, y adjunta el acuerdo firmado. Al enviarlo, el portal genera un nombre de realm aleatorio de 36 caracteres y el DID `did:web:<did_hostname>.<tailnet>:<realm>`, y lo guarda en la solicitud.

> [!NOTE]
> Por ejemplo, si el portal está en `onboarding.<tailnet>` y el nombre de realm generado es `a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8`, el DID será:
>
> ```
> did:web:onboarding-did.<tailnet>:a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8
> ``` 

### 2. Aprobación

Un administrador aprueba la solicitud en el portal de onboarding. Entonces el portal automaticamente crea el realm en Keycloak y registra el DID en el TIR. Los pasos son:

1. Crea en Keycloak el realm `<realm>` a partir de su plantilla:
   - `issuerDid` = el DID;
   - un cliente cuyo `clientId` es el DID;
   - una clave EC P-256 con certificado;
   - el ámbito de credencial `LegalPersonCredential`;
   - clientes preparados para los wallets **Lissi ID Wallet** y **EUDI Reference Wallet** (`wallet-dev`).
2. Crea en ese realm el usuario **`admin`**, con el email del solicitante, sin contraseña y con las acciones pendientes *Verify Email* y *Update Password*. Intenta enviarle esas acciones por email.
3. Registra el DID en el TIR. Si falla, borra el realm.

Si el solicitante aporta su propio DID, el portal no crea realm: solo registra ese DID en el TIR.

### 3. Activar la cuenta del administrador del participante

**Sin SMTP configurado, el email del paso anterior no sale.** En los logs del portal aparece `Unable to execute user actions … Invalid sender address 'null'`, así que el participante no puede activar su cuenta por sí mismo. Hay dos formas de resolverlo:

- **A mano, desde la consola de Keycloak:** entra en `https://onboarding-admin.<tailnet>/admin/` con `keycloak-admin`, cambia al realm del participante y ve a **Users → admin**:
  1. En **Credentials**, fija una contraseña con *Temporary* desactivado (o activado, si quieres que la cambie en su primer acceso).
  2. En **Details**, quita la acción *Verify Email* o marca el email como verificado.
- **Con correo:** configura un servidor SMTP en el realm (por ejemplo, Mailpit en local) y reenvía las acciones desde **Users → admin → Credentials → Credential reset**.

Después, el participante gestiona su organización desde la consola de **su** realm: `https://onboarding-admin.<tailnet>/admin/<realm>/console`, con el usuario `admin`. Su grupo `admin` le da permisos para gestionar usuarios (`manage-users`) y la configuración del realm (`manage-realm`), pero no para gestionar clientes.

### 4. Crear los usuarios de la organización

Cada persona de la organización que vaya a tener credencial necesita un usuario en el realm del participante. Desde la consola del realm:

1. **Users → Add user:** rellena *Username*, *Email*, *First name* y *Last name*, que son los datos que lleva la credencial, y marca *Email verified*. Pulsa *Create*.
2. **Pestaña Credentials → Set password:** fija la contraseña. Con *Temporary* activado, el usuario tendrá que cambiarla en su primer acceso.
3. **Pestaña Verifiable credentials → Create:** asigna **`LegalPersonCredential`**. **Este paso es obligatorio:** desde Keycloak 26.4 cada usuario tiene su propia lista de credenciales emitibles, y sin ella Keycloak rechaza la oferta con `User '<usuario>' does not have verifiable credential 'LegalPersonCredential'`. El usuario `admin` que crea el portal ya la tiene asignada.
4. **Roles (opcional):** la credencial incluye un *claim* `roles` con los roles que tenga el usuario en el cliente del DID (el cliente cuyo `clientId` es el DID del participante):

   ```json
   "roles": [{ "names": ["OPERATOR"], "target": "did:web:onboarding-did.<tailnet>:<realm>" }]
   ```

   Es lo que usan las políticas de acceso de los proveedores del espacio de datos. El cliente se crea sin roles, así que primero hay que crearlos en **Clients → `<DID>` → Roles → Create role** (por ejemplo `OPERATOR` o `READER`, según lo que acuerden los proveedores), y después asignarlos en **Users → `<usuario>` → Role mapping → Assign role**, filtrando por roles de clientes. Crear roles de cliente requiere permisos de gestión de clientes, que el `admin` del participante no tiene: lo hace `keycloak-admin`.

Por API, la asignación de la credencial es `POST /admin/realms/<realm>/users/<id>/vc/credentials` con `{"credentialScopeName": "LegalPersonCredential"}`. El campo `verifiableCredentials` de la representación del usuario solo se respeta al crearlo: en un `PUT` se ignora.

### 5. Obtener la credencial (OID4VCI)

El realm del participante es un **emisor de credenciales verificables**:

| | |
|---|---|
| Metadatos del emisor | `https://onboarding-admin.<tailnet>/realms/<realm>/.well-known/openid-credential-issuer` |
| Credencial | `LegalPersonCredential`, formato `dc+sd-jwt` (SD-JWT VC) |
| Contenido | Visibles: `iss` (el DID del participante), `vct`, `email`, `roles` y `cnf`. Revelables de forma selectiva: `firstName`, `lastName` y `jti` |
| Firma | Clave EC P-256 del realm (ES256), verificable resolviendo el DID del emisor |
| Ligada al titular | Sí: al pedirla hay que presentar una prueba JWT firmada con la clave del wallet, que queda en el *claim* `cnf` |

Al estar ligada a la clave del titular, la credencial se obtiene con un **wallet** o con un script que haga de wallet. Keycloak 26.7 admite dos flujos:

**A. Oferta de credencial (código pre-autorizado)**, probado de punta a punta:

1. **Pedir la oferta:** con un token del usuario, `GET /realms/<realm>/protocol/oid4vc/create-credential-offer?credential_configuration_id=LegalPersonCredential&pre_authorized=true`. Keycloak responde `{"issuer": "<url>", "nonce": "<id>"}`, y la oferta está en `<issuer>/<nonce>`. Para un wallet se entrega como enlace o QR: `openid-credential-offer://?credential_offer_uri=<issuer>/<nonce>` (codificado como URL).
   - Para la prueba, el token del usuario se obtuvo con el cliente del DID, que es confidencial (su secreto está en **Clients → `<DID>` → Credentials**), con `grant_type=password` y `scope=openid LegalPersonCredential`.
2. **Leer la oferta** (`GET <issuer>/<nonce>`): contiene el `pre-authorized_code`.
3. **Canjear el código** en el endpoint de token del realm: `grant_type=urn:ietf:params:oauth:grant-type:pre-authorized_code`. La respuesta incluye `authorization_details` con el identificador de la credencial (por ejemplo `LegalPersonCredential_0000`).
4. **Pedir un nonce:** `POST /realms/<realm>/protocol/oid4vc/nonce`, que devuelve `c_nonce`.
5. **Pedir la credencial:** `POST /realms/<realm>/protocol/oid4vc/credential`, con el token y el cuerpo:

   ```json
   { "credential_identifier": "LegalPersonCredential_0000",
     "proofs": { "jwt": ["<JWT de prueba>"] } }
   ```

   El JWT de prueba lleva la cabecera `{"typ": "openid4vci-proof+jwt", "alg": "ES256", "jwk": <clave pública del wallet>}` y el cuerpo `{"aud": "<issuer del realm>", "iat": <ahora>, "nonce": "<c_nonce>"}`, firmado con la clave privada del wallet. Keycloak 26.7 sigue OID4VCI 1.0: exige `credential_identifier` (pedirla por `credential_configuration_id` da error) y `proofs` en lugar de `proof`.
6. La respuesta trae la credencial en `credentials[0].credential`.

**B. Iniciado por el wallet (código de autorización):** el wallet abre el login del realm en el navegador, el usuario entra con su cuenta y el wallet recibe la credencial. El realm ya trae clientes para **Lissi ID Wallet** y para la **EUDI Reference Wallet** (`wallet-dev`). Este flujo no se ha probado.

Requisitos y notas:

- Si el wallet está en un móvil, el móvil tiene que estar en la Tailnet (con la app de Tailscale), porque Keycloak solo es accesible en `onboarding-admin.<tailnet>.ts.net`. Con certificados de producción el wallet confía en él; con *staging* no.
- Para verificar una credencial, el verificador resuelve el DID del emisor a través del did-helper (`https://onboarding-did.<tailnet>/<realm>/did.json`), comprueba la firma con la clave cuyo `kid` indica la credencial, y comprueba en el TIR que ese DID es un participante de confianza.
- **Probado** en un realm creado con la plantilla del portal: flujo A completo, con la firma de la credencial verificada usando la clave obtenida al resolver el DID con el did-helper, y con el *claim* `roles` tras asignar un rol del cliente del DID.

## Limitaciones

- **Sin SMTP:** el administrador de cada participante no recibe el email de activación (ver [paso 3](#3-activar-la-cuenta-del-administrador-del-participante)).
- **Hostname del did-helper:** forma parte de cada DID emitido. Cambiarlo, o cambiar de Tailnet, invalida los DIDs existentes.
- **Accesibilidad de los DIDs:** solo se resuelven dentro de la Tailnet. Para participantes externos, el host de los DIDs necesitaría un dominio público.
- **Certificados:** el did-helper necesita un certificado válido, así que le afecta el límite de Let's Encrypt al reconstruir el clúster.

## Requisitos

- `modules/tailscale` con egress habilitado (lo está por defecto): ProxyGroup de egress y zona `ts.net` en CoreDNS.
- `modules/vault` y una instancia de `modules/postgres`.
- Los providers `helm`, `kubernetes` y `alekc/kubectl` configurados en el use case.

## Uso

Ver `use_cases/local_dataspace/main.tf`.
