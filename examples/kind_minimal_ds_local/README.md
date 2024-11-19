# Minimal Data Space Local - Kind Cluster

This example is based on the [FIWARE's local deployment](https://github.com/FIWARE/data-space-connector/blob/main/doc/deployment-integration/local-deployment/LOCAL.MD). The main difference is that we are using a Kind cluster (with 3 nodes) and Terraform to manage all the resources.

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
        <a href="#deployment">Deployment</a>
        <ul>
            <li><a href="#cluster-access">Cluster Access</a></li>
            <li><a href="#deployment-time--monitoring">Deployment Time & Monitoring</a></li>
            <li><a href="#access-to-the-services">Access to the services</a>
                <ul>
                    <li><a href="#ingress-dashboard-traefik">Ingress Dashboard (Traefik)</a></li>
                    <li><a href="#connector-services">Connector services</a></li>
                </ul>
            </li>
        </ul>
    </li>
    <li>
        <a href="#cheetsheet">Cheetsheet</a>
    </li>
  </ol>
</details>

The following diagram shows the main blocks of the architecture of the minimal data space. This example is composed of the following blocks:

- **Fiware Data Space (FDS) Operator or Trust Anchor**: Trust Anchor that manages the issuers and credentials.
- **FDS Connector A (Provider)**: Entity that provides and consumes data from the data space.
- **FDS Connector B (Consumer)**: Entity that only consumes data from the data space.

![minimal_ds](./images/minimum_dataspace_arch.png)

> [!NOTE]
>
> The terraform source code for each component is [here](../../modules/fiware_ds_connector/).

## Deployment

To deploy the minimal data space, you need to execute the following command:

```bash
make init_apply
```

### Cluster access

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

### Deployment Time & Monitoring

Depending on the resources of your machine, the deployment time can vary. In general, the deployment time is around **10 minutes** or more. 

This deployment have two phases: 

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

### Access to the services

With the environment deployed, you can access the services using the following domain names:

> [!WARNING]
>
> **Temporary Solution** Also to access to the different services, you need to add all domain names to your `/etc/hosts` file.
>
> 1. Check the Traefik IP address: 
>
> ```bash
> kubectl get services -n traefik-ingress --kubeconfig ./cluster-config.yaml
> NAME                        TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)          AGE
> traefik-dashboard-service   LoadBalancer   10.96.97.1    172.18.255.201   8080:30137/TCP   10m
>traefik-web-service         LoadBalancer   10.96.72.80   172.18.255.200   80:31910/TCP     10m
> ```
>
> 2. Add the domain names to your `/etc/hosts` file:
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

#### Ingress Dashboard (Traefik)

Traefik dashboard: `http://172.19.255.201:8080/dashboard#`

#### Connector services

**Trust-Anchor**

```bash
curl -s -XGET http://tir.ds-operator.local/v4/issuers | jq


{
  "self": "/v4/issuers/",
  "items": [
    {
      "did": "did:key:zDnaedBWBYNtDsCNqxqBbshP7p5RuEuFo5emku1ack3XzvvoU",
      "href": "/v4/issuers/did:key:zDnaedBWBYNtDsCNqxqBbshP7p5RuEuFo5emku1ack3XzvvoU"
    },
    {
      "did": "did:key:zDnaezQYkXpLUpp4vXRS3DiQFhaHhWkPQphdVqCarsPuNbz95",
      "href": "/v4/issuers/did:key:zDnaezQYkXpLUpp4vXRS3DiQFhaHhWkPQphdVqCarsPuNbz95"
    }
  ],
  "total": 2,
  "pageSize": 2,
  "links": {
    "first": "did:key:zDnaedBWBYNtDsCNqxqBbshP7p5RuEuFo5emku1ack3XzvvoU"
  }
}
```

**Paricipants**

Keycloak:

- Admin console: `http://keycloak.consumer-a.local`
- Realm (*test-user* | *test*): `http://keycloak.consumer-a.local/realms/test-realm/account/oid4vci`


Retrieve an actual credential:

```bash
unset ACCESS_TOKEN; unset OFFER_URI; unset PRE_AUTHORIZED_CODE; \
unset CREDENTIAL_ACCESS_TOKEN; unset VERIFIABLE_CREDENTIAL; unset HOLDER_DID; \
unset VERIFIABLE_PRESENTATION; unset JWT_HEADER; unset PAYLOAD; unset SIGNATURE; unset JWT; \
unset VP_TOKEN; unset DATA_SERVICE_ACCESS_TOKEN;
```

```bash
export ACCESS_TOKEN=$(curl -s -X POST "http://keycloak.consumer-a.local/realms/test-realm/protocol/openid-connect/token" \
  --header 'Accept: */*' \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data grant_type=password \
  --data client_id=admin-cli \
  --data username=test-user \
  --data password=test | jq '.access_token' -r); echo -e "\n>> Access token: $ACCESS_TOKEN"
```

```bash
curl -s -X GET http://keycloak.consumer-a.local/realms/test-realm/.well-known/openid-credential-issuer | jq
```

```bash
export OFFER_URI=$(curl -s -X GET "http://keycloak.consumer-a.local/realms/test-realm/protocol/oid4vc/credential-offer-uri?credential_configuration_id=user-credential" \
  --header "Authorization: Bearer ${ACCESS_TOKEN}" | jq '"\(.issuer)\(.nonce)"' -r); echo -e "\n>> Offer URI: $OFFER_URI"

export PRE_AUTHORIZED_CODE=$(curl -s -X GET ${OFFER_URI} \
  --header "Authorization: Bearer ${ACCESS_TOKEN}" | jq '.grants."urn:ietf:params:oauth:grant-type:pre-authorized_code"."pre-authorized_code"' -r); echo -e "\n>> Pre-authorized code: $PRE_AUTHORIZED_CODE"

export CREDENTIAL_ACCESS_TOKEN=$(curl -s -X POST "http://keycloak.consumer-a.local/realms/test-realm/protocol/openid-connect/token" \
  --header 'Accept: */*' \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data grant_type=urn:ietf:params:oauth:grant-type:pre-authorized_code \
  --data code=${PRE_AUTHORIZED_CODE} | jq '.access_token' -r); echo -e "\n>> Credential access token: $CREDENTIAL"

export VERIFIABLE_CREDENTIAL=$(curl -s -X POST "http://keycloak.consumer-a.local/realms/test-realm/protocol/oid4vc/credential" \
  --header 'Accept: */*' \
  --header 'Content-Type: application/json' \
  --header "Authorization: Bearer ${CREDENTIAL_ACCESS_TOKEN}" \
  --data '{"credential_identifier":"user-credential", "format":"jwt_vc"}' | jq '.credential' -r);echo -e "\n>> Verifiable credential: $VERIFIABLE_CREDENTIAL"
```

Authenticate via OID4VP

```bash
export TOKEN_ENDPOINT=$(curl -s -X GET 'http:/apisix-proxy.provider-a.local/.well-known/openid-configuration' | jq -r '.token_endpoint'); echo -e "\n>> Token endpoint $TOKEN_ENDPOINT"
```

```bash
docker run -v $(pwd):/cert quay.io/wi_stefan/did-helper:0.1.1
```

```bash
export HOLDER_DID=$(cat did.json | jq '.id' -r); echo -e "\n>> Holder DID: $HOLDER_DID"

export VERIFIABLE_PRESENTATION="{
  \"@context\": [\"https://www.w3.org/2018/credentials/v1\"],
  \"type\": [\"VerifiablePresentation\"],
  \"verifiableCredential\": [
      \"${VERIFIABLE_CREDENTIAL}\"
  ],
  \"holder\": \"${HOLDER_DID}\"
}"; echo -e "\n>> Verifiable presentation: $VERIFIABLE_PRESENTATION"

export JWT_HEADER=$(echo -n "{\"alg\":\"ES256\", \"typ\":\"JWT\", \"kid\":\"${HOLDER_DID}\"}"| base64 -w0 | sed s/\+/-/g | sed 's/\//_/g' | sed -E s/=+$//); echo -e "\n>> JWT header: $JWT_HEADER"

export PAYLOAD=$(echo -n "{\"iss\": \"${HOLDER_DID}\", \"sub\": \"${HOLDER_DID}\", \"vp\": ${VERIFIABLE_PRESENTATION}}" | base64 -w0 | sed s/\+/-/g |sed 's/\//_/g' |  sed -E s/=+$//); echo -e "\n>> Payload: $PAYLOAD"

export SIGNATURE=$(echo -n "${JWT_HEADER}.${PAYLOAD}" | openssl dgst -sha256 -binary -sign private-key.pem | base64 -w0 | sed s/\+/-/g | sed 's/\//_/g' | sed -E s/=+$//); echo -e "\n >> Signature: $SIGNATURE"

export JWT="${JWT_HEADER}.${PAYLOAD}.${SIGNATURE}"; echo -e "\n>> JWT: $JWT"

export VP_TOKEN=$(echo -n ${JWT} | base64 -w0 | sed s/\+/-/g | sed 's/\//_/g' | sed -E s/=+$//); echo -e "\n>> VP token: $VP_TOKEN"

export DATA_SERVICE_ACCESS_TOKEN=$(curl -s -X POST $TOKEN_ENDPOINT \
    --header 'Accept: */*' \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data grant_type=vp_token \
    --data vp_token=${VP_TOKEN} \
    --data scope=default | jq '.access_token' -r ); echo -e "\n>> Data service access token: $DATA_SERVICE_ACCESS_TOKEN"
```



## Cheetsheet

- Get the pods status:
```bash
watch kubectl get pods --context kind-minimal-dataspace-cluster --kubeconfig ./cluster-config.yaml --all-namespaces
```

```bash
watch kubectl get pods --context kind-minimal-dataspace-cluster --kubeconfig ./cluster-config.yaml -n provider-a
```

- Get all certificates:
```bash
  kubectl get cert --context kind-minimal-dataspace-cluster --kubeconfig ./cluster-config.yaml --all-namespaces
```

- Get all secrets:
```bash
  kubectl get secrets --context kind-minimal-dataspace-cluster --kubeconfig ./cluster-config.yaml --all-namespaces
```

- Get secrect content:
```bash
  kubectl get secret --context kind-minimal-dataspace-cluster --kubeconfig ./cluster-config.yaml -n <namespace_name> <secret_name> -o jsonpath="{.data['tls\.crt']}" | base64 --decode

  kubectl get secret --context kind-minimal-dataspace-cluster --kubeconfig ./cluster-config.yaml -n ds-operator mysql-database-secret -o json

  kubectl get secret --context kind-minimal-dataspace-cluster --kubeconfig ./cluster-config.yaml -n ds-operator mysql-database-secret -o jsonpath="{.data}" | jq

  kubectl get secret --context kind-minimal-dataspace-cluster --kubeconfig ./cluster-config.yaml -n ds-operator mysql-database-secret -o json | jq -r '.data | to_entries[] | .key + ": " + (.value | @base64d)'
```
