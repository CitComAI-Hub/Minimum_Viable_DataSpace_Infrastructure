# Raw Fiware Data Space Consumer

This is a minimal example, without any predefined configurations for a data space that only includes a **Trust Anchor** and a Fiware connector with the **consumer** role.

**Table of Contents:**

- [How run the example?](#how-run-the-example-back-to-top)
- [Data Space Operator](#data-space-operator-trust-anchor-back-to-top)
- [Fiware Connector Consumer (Keycloak)](#fiware-connector-consumer-keycloak-back-to-top)


![arch](./images/example_arch.svg)

Having no predefined configurations means that there is no DID registered at the Trust Anchor and the Fiware consumer does not have any client set up.

- **Fiware Trust Anchor:** Data space operator, without any DID registered.
- **Fiware Consumer:** Data space consumer, without any client set up.


## How run the example? ([_back to top_](#raw-fiware-data-space-consumer))

The main processes to run the example are predefined in the Makefile. To run the example, you should execute the following command:

| Command | Description |
| ------- | ----------- |
| `make init_cluster` | Kind cluster and Fiware components deployment. |
| `make init_apply` | ONLY Fiware components deployment (kubernetes cluster no changed). |
| | |
| `make destroy` | Remove ONLY Fiware components. |
| `make destroy_cluster` | Remove Fiware components and the kind cluster. |

> [!WARNING]
>
> The deployment time is around **14 minutes** (depending on the resources of your machine, this time can vary).

## Data Space Operator (Trust Anchor) ([_back to top_](#raw-fiware-data-space-consumer))

Data Space Operator is the entity that manages the Data Space. It is responsible for maintaining a registry of the participants' issuer DIDs. In this case, the Data Space Operator is the **Trust Anchor**.

List did registries:

```bash
> curl -s -X GET "http://172.18.255.200/v4/issuers" -H "Host: tir.ds-operator.local" | jq
{
  "title": "Internal Server Error",
  "status": 500,
  "detail": "Request could not be answered due to an unexpected internal error."
}
```

## Fiware Connector Consumer (Keycloak) ([_back to top_](#raw-fiware-data-space-consumer))

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
