# Minimal Data Space Local - Kind Cluster

This example is based on the [FIWARE's local deployment](https://github.com/FIWARE/data-space-connector/blob/main/doc/deployment-integration/local-deployment/LOCAL.MD). The main difference is that we are using a Kind cluster (with 3 nodes) and Terraform to manage all the resources.

**Table of Contents:**

1. [Deployment](#1-deployment-back-to-top)
    - [Cluster Access](#11-cluster-access-back-to-top)
    - [Check & Monitoring](#12-check--monitoring-back-to-top)
    - [Access to the services](#13-access-to-the-services-back-to-top)
        - [Ingress Dashboard (Traefik)](#ingress-dashboard-traefik)
        - [Consumer](#consumer-back-to-top)
        - [Provider](#provider-back-to-top)
- [] [Examples](#examples-back-to-top)

The following diagram shows the main blocks of the architecture of the minimal data space. This example is composed of the following blocks:

- **Fiware Data Space (FDS) Operator or Trust Anchor**: Trust Anchor that manages the issuers and credentials.
- **FDS Connector A (Provider)**: Entity that provides and consumes data from the data space.
- **FDS Connector B (Consumer)**: Entity that only consumes data from the data space.

![minimal_ds](./images/minimum_dataspace_arch.svg)

> [!NOTE]
>
> The terraform source code for each component is [here](../../modules/fiware_ds_connector/).

## 1. Deployment ([_back to top_](#minimal-data-space-local---kind-cluster))

<!-- TODO: PERMISOS CARPETAS DE SCRIPTS:

  sudo chmod +x ../../modules/kind/metal_lb/scripts/get_ips.sh
  sudo chmod +x ../../modules/ca_configuration/scripts/generate_ca_certificates.sh -->

From `<repo_path>/examples/kind_minimal_ds_local` folder, you need to execute the following commands:

To deploy the minimal data space, you need to execute the following command:

```bash
make init_apply
```

> [!!WARNING]
>
> The deployment time is around **10 minutes** (depending on the resources of your machine, this time can vary).

### 1.1. Cluster access ([_back to top_](#minimal-data-space-local---kind-cluster))

The kubeconfig file is generated in the `./cluster-config.yaml` file. To access the cluster, there are two options:

1. Exporting the `KUBECONFIG` variable:
  ```bash
  export KUBECONFIG=./cluster-config.yaml
  kubectl get pods --all-namespaces
  ```
2. Using the `--kubeconfig` flag:
  ```bash
  kubectl get nodes --kubeconfig ./cluster-config.yaml --all-namespaces
  ```

### 1.2. Check & Monitoring ([_back to top_](#minimal-data-space-local---kind-cluster))

To check the deployment status, it is important to know that there are two phases:

1. **Kind** (Kubernetes cluster): The first phase is the creation of the Kind cluster. You can check the cluster using docker:
  ```bash
  docker ps

  CONTAINER ID   IMAGE                  COMMAND                  CREATED       STATUS       PORTS                                                                 NAMES
  1eadbf764cda   kindest/node:v1.29.2   "/usr/local/bin/entr…"   2 hours ago   Up 2 hours                                                                         cluster-minimal-ds-worker
  70f36edee4f8   kindest/node:v1.29.2   "/usr/local/bin/entr…"   2 hours ago   Up 2 hours   0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp, 127.0.0.1:43937->6443/tcp   cluster-minimal-ds-control-plane
  8bcb3357be83   kindest/node:v1.29.2   "/usr/local/bin/entr…"   2 hours ago   Up 2 hours                                                                         cluster-minimal-ds-worker2
  ```
2. **Connector**: The second phase is the deployment of the minimal data space. As this is the most time-consuming phase, you can check the status of the pods using the following command:
  ```bash
  watch kubectl get pods --all-namespaces
  ```
  or 
  ```bash
  watch kubectl get pods --kubeconfig ./cluster-config.yaml --all-namespaces
  ```
  That command will show the status of the pods in real-time.

  ```bash
  NAMESPACE            NAME                                                        READY   STATUS      RESTARTS       AGE
  cert-manager         cert-manager-6d988558d6-q7pcs                               1/1     Running     0              132m
  cert-manager         cert-manager-cainjector-6976895488-dpwh4                    1/1     Running     0              132m
  cert-manager         cert-manager-webhook-fcf48cc54-tj7tx                        1/1     Running     0              132m
  cert-manager         trust-manager-775bfcf747-gpmqb                              1/1     Running     0              131m
  consumer-a           did-helper-596df479dc-td66f                                 1/1     Running     0              114m
  consumer-a           dsconfig-8fcdb84b7-pc26b                                    1/1     Running     0              114m
  consumer-a           keycloak-0                                                  1/1     Running     0              114m
  consumer-a           postgresql-0                                                1/1     Running     0              114m
  ds-operator          mysql-0                                                     1/1     Running     0              130m
  ds-operator          trusted-issuers-list-85c5765cb4-n7r8n                       1/1     Running     3 (128m ago)   130m
  kube-system          coredns-76f75df574-g42xv                                    1/1     Running     0              134m
  kube-system          coredns-76f75df574-sm58c                                    1/1     Running     0              134m
  kube-system          etcd-cluster-minimal-ds-control-plane                       1/1     Running     0              134m
  kube-system          kindnet-fqsmz                                               1/1     Running     0              134m
  kube-system          kindnet-lxw8f                                               1/1     Running     0              134m
  kube-system          kindnet-qvkll                                               1/1     Running     0              134m
  kube-system          kube-apiserver-cluster-minimal-ds-control-plane             1/1     Running     0              134m
  kube-system          kube-controller-manager-cluster-minimal-ds-control-plane    1/1     Running     0              134m
  kube-system          kube-proxy-57vtq                                            1/1     Running     0              134m
  kube-system          kube-proxy-c8cnv                                            1/1     Running     0              134m
  kube-system          kube-proxy-jhz5b                                            1/1     Running     0              134m
  kube-system          kube-scheduler-cluster-minimal-ds-control-plane             1/1     Running     0              134m
  local-path-storage   local-path-provisioner-7577fdbbfb-8qxwq                     1/1     Running     0              134m
  metallb-system       controller-67d9f4b5bc-fkq8n                                 1/1     Running     0              133m
  metallb-system       speaker-lrqjr                                               1/1     Running     0              133m
  metallb-system       speaker-tjdvg                                               1/1     Running     0              133m
  metallb-system       speaker-wblpx                                               1/1     Running     0              133m
  provider-a           apisix-proxy-control-plane-6f7664c8ff-nmx5g                 1/1     Running     0              126m
  provider-a           apisix-proxy-data-plane-644f6d76dd-l6jxf                    2/2     Running     0              126m
  provider-a           contract-management-6fdf575454-vjzkq                        1/1     Running     0              126m
  provider-a           credentials-config-service-64bdb5d4f7-mr8sn                 1/1     Running     0              126m
  provider-a           did-helper-7c88f8cfcd-5qssl                                 1/1     Running     0              126m
  provider-a           dsconfig-8fcdb84b7-xg8f9                                    1/1     Running     0              126m
  provider-a           fiware-data-space-connector-etcd-0                          1/1     Running     0              126m
  provider-a           fiware-data-space-connector-etcd-1                          1/1     Running     0              126m
  provider-a           fiware-data-space-connector-etcd-2                          1/1     Running     2 (121m ago)   126m
  provider-a           mysql-db-0                                                  1/1     Running     0              126m
  provider-a           pap-odrl-55745c6cb4-zvqbs                                   1/1     Running     0              126m
  provider-a           postgis-db-0                                                1/1     Running     0              126m
  provider-a           postgresql-db-0                                             1/1     Running     0              126m
  provider-a           scorpio-broker-5ccf978d57-wm5bp                             1/1     Running     0              126m
  provider-a           tm-forum-api-customer-bill-management-67d579485d-b8tqr      1/1     Running     0              126m
  provider-a           tm-forum-api-customer-management-684564489f-qjmw8           1/1     Running     0              126m
  provider-a           tm-forum-api-envoy-654894667-xf6m8                          1/1     Running     0              126m
  provider-a           tm-forum-api-party-catalog-5d7754bbb-gn2sz                  1/1     Running     0              126m
  provider-a           tm-forum-api-product-catalog-7b459df5f8-jxs9f               1/1     Running     0              126m
  provider-a           tm-forum-api-product-inventory-8888bdf67-bj5qh              1/1     Running     0              126m
  provider-a           tm-forum-api-product-ordering-management-56fd45cbb6-n9lh4   1/1     Running     0              126m
  provider-a           tm-forum-api-registration-6pvn2                             0/1     Completed   0              119m
  provider-a           tm-forum-api-registration-8mfs9                             0/1     Error       0              126m
  provider-a           tm-forum-api-registration-k756g                             0/1     Error       0              120m
  provider-a           tm-forum-api-registration-tvvb9                             0/1     Error       0              123m
  provider-a           tm-forum-api-resource-catalog-77547c969f-dgcx8              1/1     Running     0              126m
  provider-a           tm-forum-api-resource-function-activation-6d8d9ff64-7mxg9   1/1     Running     0              126m
  provider-a           tm-forum-api-resource-inventory-7d74964c94-xvhqd            1/1     Running     0              126m
  provider-a           tm-forum-api-service-catalog-86b94485d-5ngkh                1/1     Running     0              126m
  provider-a           trusted-issuers-list-65b7fbd6fd-hbrxv                       1/1     Running     0              126m
  provider-a           vc-verifier-7f8b6666db-n2vlb                                1/1     Running     0              126m
  traefik-ingress      traefik-deployment-7489799fff-d4ffk                         1/1     Running     0              132m
  ```

### 1.3. Access to the services ([_back to top_](#minimal-data-space-local---kind-cluster))

With the environment deployed, you can access the services using the following domain names:

> [!WARNING]
>
> **Temporary Solution** Also to access to the different services, you need to add all domain names to your `/etc/hosts` file.
>
> ```bash
> 172.19.255.200     did-helper.consumer-a.local
> 172.19.255.200     keycloak.consumer-a.local
> 172.19.255.200     til.ds-operator.local
> 172.19.255.200     tir.ds-operator.local
> 172.19.255.200     apisix-proxy.provider-a.local
> 172.19.255.200     apisix-api.provider-a.local
> 172.19.255.200     did-helper.provider-a.local
> 172.19.255.200     pap-odrl.provider-a.local
> 172.19.255.200     scorpio-broker.provider-a.local
> 172.19.255.200     tm-forum-api.provider-a.local
> 172.19.255.200     til.provider-a.local
> 172.19.255.200     vc-verifier.provider-a.local
> ```

| Service |              Domain Name                |    Description    | Data Space Role |
|---------|-----------------------------------------|-------------------|-----------------|
| Traefik | `http://172.19.255.201:8080/dashboard#` | Ingress dashboard | - |
| Trusted Issuer List | `http://til.ds-operator.local` | Register new issuer | Trust-Anchor |
| Trusted Issuer List | `http://tir.ds-operator.local` | List issuers | Trust-Anchor |
| Keycloak | `http://keycloak.consumer-a.local`     | Admin console | Consumer |
| Keycloak | `http://keycloak.consumer-a.local/realms/test-realm/account/oid4vci` | User console | Consumer |
| Gateway | `http://apisix-proxy.provider-a.local`  | APISIX proxy | Provider |

#### Ingress Dashboard (Traefik) ([_back to top_](#minimal-data-space-local---kind-cluster))

To access the Traefik dashboard, you need to use the following URL: `http://172.19.255.201:8080/dashboard#`

![ingress_dashboard](./images/ingress_dashboard.png)

You can check the services and the routes created by the Ingress Controller:

```bash
kubectl get services -n traefik-ingress --kubeconfig ./cluster-config.yaml
NAME                        TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)          AGE
traefik-dashboard-service   LoadBalancer   10.96.97.1    172.18.255.201   8080:30137/TCP   10m
traefik-web-service         LoadBalancer   10.96.72.80   172.18.255.200   80:31910/TCP     10m
```

#### Consumer ([_back to top_](#minimal-data-space-local---kind-cluster))

**Keycloak:**

Keycloak can be used to issue VerifiableCredentials for users or services, to be used for authorization at other participants of the Data Space. By default, Keyclok if pre-configured with two users:

| User             | Password                       | Role  |
|------------------|--------------------------------|-------|
| `keycloak-admin` | (generated durind deployment)¹ | Admin |
| `test-user`      | `test`                         | User  |

> [!NOTE]
>
>¹To get the password, you can check the logs of the Keycloak pod:
>```bash
>kubectl get secret issuance-secret -n consumer-a -o json | jq '.data."keycloak-admin"' -r | base64 --decode
>```

To get access to the data space, you need to create a Verifiable Credential. Verifiable credential (in jwt (_JSON Web Token_) format _header.payload.signature_):

```
eyJhbGciOiJFUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJkaWQ6a2V5OnpEbmFlVzZuTlVpUXhWbTlON3d0VWVIUmNwb2hobXQ2OHh1b3l6VGVjWEsxRTZ3WXMifQ.eyJuYmYiOjE3MzIwOTM4NTMsImp0aSI6InVybjp1dWlkOmFkOGM2MmI4LTk4MjktNGQ4YS05ZWEzLTM1YWFmZDM1ZjQyNCIsImlzcyI6ImRpZDprZXk6ekRuYWVXNm5OVWlReFZtOU43d3RVZUhSY3BvaGhtdDY4eHVveXpUZWNYSzFFNndZcyIsInZjIjp7InR5cGUiOlsiVXNlckNyZWRlbnRpYWwiXSwiaXNzdWVyIjoiZGlkOmtleTp6RG5hZVc2bk5VaVF4Vm05Tjd3dFVlSFJjcG9oaG10Njh4dW95elRlY1hLMUU2d1lzIiwiaXNzdWFuY2VEYXRlIjoxNzMyMDkzODUzNzgyLCJjcmVkZW50aWFsU3ViamVjdCI6eyJmaXJzdE5hbWUiOiJUZXN0IiwibGFzdE5hbWUiOiJSZWFkZXIiLCJlbWFpbCI6InRlc3RAdXNlci5vcmcifSwiQGNvbnRleHQiOlsiaHR0cHM6Ly93d3cudzMub3JnLzIwMTgvY3JlZGVudGlhbHMvdjEiXX19.ddd2s3AIu_d1t-14Fljkj-4siBI6rEt6m6WStKBwodVG0OGSsg6zGOMqRi_5jpPH3KIrBkCGixR3PCNwd-_Cew
```

If you decode the jwt, you will get the following information (_you can use this website [jwt.io](https://jwt.io/)_):

```json
{
  "alg": "ES256",
  "typ": "JWT",
  "kid": "did:key:zDnaeW6nNUiQxVm9N7wtUeHRcpohhmt68xuoyzTecXK1E6wYs"
},
{
  "nbf": 1732093853,
  "jti": "urn:uuid:ad8c62b8-9829-4d8a-9ea3-35aafd35f424",
  "iss": "did:key:zDnaeW6nNUiQxVm9N7wtUeHRcpohhmt68xuoyzTecXK1E6wYs",
  "vc": {
    "type": [
      "UserCredential"
    ],
    "issuer": "did:key:zDnaeW6nNUiQxVm9N7wtUeHRcpohhmt68xuoyzTecXK1E6wYs",
    "issuanceDate": 1732093853782,
    "credentialSubject": {
      "firstName": "Test",
      "lastName": "Reader",
      "email": "test@user.org"
    },
    "@context": [
      "https://www.w3.org/2018/credentials/v1"
    ]
  }
},
{(signature content)}
```

#### Provider ([_back to top_](#minimal-data-space-local---kind-cluster))

- [ ] Steps to create a data policy and data creation in the broker for an example.

## Examples ([_back to top_](#minimal-data-space-local---kind-cluster))
