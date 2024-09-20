# Minimal Data Space Local - Kind Cluster

![minimal_ds](../images/minimum_dataspace_arch.png)

## DS Operator (Trust Anchor)

Get ingress domain name:

```bash
kubectl get ingress -n ds-operator --kubeconfig ./cluster-config.yaml
```

Add the domain name to your `/etc/hosts` file:

```bash
127.0.0.1       til.ds-operator.local
127.0.0.1       tir.ds-operator.local
```

Create a new issuer:

```bash
curl -X POST http://til.ds-operator.local/issuer \
    --header 'Content-Type: application/json' \
    --data '{
        "did": "did:key:myKey",
        "credentials": []
}'
```

Get the list of issuers:

```bash
curl -X GET http://tir.ds-operator.local/v4/issuers
```