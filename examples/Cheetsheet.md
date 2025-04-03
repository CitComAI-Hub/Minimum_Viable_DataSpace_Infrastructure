# Cheetsheet

## Kubernetes

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

- Get ingress details for specific pod:

```bash
  kubectl get ingress apisix-proxy-data-plane -n provider-a -o yaml
```