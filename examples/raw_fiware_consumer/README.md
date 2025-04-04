# Raw Fiware Data Source Example

In this example, a Trust Anchor and a Data Space Consumer (Keycloak) are deployed on a Kubernetes (Kind) cluster. Both components (Trust Anchor and Keycloak) are deployed without any default configuration, which means:

- **Trust Anchor:** has no DID registered.
- **Keycloak:** has no client configured.

## Trust Anchor

List did registries:

```bash
> curl -s -X GET "http://172.18.255.200/v4/issuers" -H "Host: tir.ds-operator.local" | jq
{
  "title": "Internal Server Error",
  "status": 500,
  "detail": "Request could not be answered due to an unexpected internal error."
}
```

## Consumer (Keycloak)

Get issuer did:

```bash
> kubectl exec -it keycloak-0 -n consumer-a -- bash

keycloak@keycloak-0:/$ cat /did-material/did.env 
DID=did:key:zDnaenz8Uf2fZe5ym74mSDEXxDPwHhCt42wcgwGkvMfSH5GVg
PROVIDER_DID=did:key:zDnaeT9u7vErBkfFi1ufAZprjsjjvKwEEWDvBNTqBKBo9NeNs
```

Web access:

Keycloak can be used to issue VerifiableCredentials for users or services, to be used for authorization at other participants of the Data Space. It comes with 1 preconfigured users:

- the `keycloak-admin`: has a password generated during deployment, it can be retrieved via:
    ```bash
    kubectl get secret -n consumer-a -o json issuance-secret | jq '.data."keycloak-admin"' -r | base64 --decode
    ```

Add `172.18.255.200     keycloak.consumer-a.local` to /etc/hosts.

The admin-console of keycloak is available at: http://keycloak.consumer-a.local, login with the keycloak-admin
