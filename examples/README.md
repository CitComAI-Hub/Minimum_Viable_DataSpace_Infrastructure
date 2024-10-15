# Examples developed

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
        <a href="#kind-cluster">Kind Cluster</a>
        <ul>
            <li><a href="#cheatsheet">Cheatsheet</a></li>
      </ul>
    </li>
    <li><a href="#minimal-ds">Minimal DS</a></li>
  </ol>
</details>

## Kind Cluster

**Source:** [kind_cluster](kind_cluster/)

### Cheatsheet

## Minimal Data Space

Minimal Data Space deployment.

**Source:** [minimal_ds](kind_minimal_ds_local/)

![minimal_ds](images/minimum_dataspace_arch.png)

### Cheetsheet

- Get the pods status:
```bash
watch kubectl get pods --context kind-minimal-dataspace-cluster --kubeconfig ~/.kube/config_minimalDS --all-namespaces
```

```bash
watch kubectl get pods --context kind-minimal-dataspace-cluster --kubeconfig ~/.kube/config_minimalDS -n ds-connector-a
```

- Get all certificates:
```bash
  kubectl get cert --context kind-minimal-dataspace-cluster --kubeconfig ~/.kube/config_minimalDS --all-namespaces
```

- Get all secrets:
```bash
  kubectl get secrets --context kind-minimal-dataspace-cluster --kubeconfig ~/.kube/config_minimalDS --all-namespaces
```

- Get secrect content:
```bash
  kubectl get secret --context kind-minimal-dataspace-cluster --kubeconfig ~/.kube/config_minimalDS -n <namespace_name> <secret_name> -o jsonpath="{.data['tls\.crt']}" | base64 --decode

  kubectl get secret --context kind-minimal-dataspace-cluster --kubeconfig ~/.kube/config_minimalDS -n ds-operator mysql-database-secret -o json

  kubectl get secret --context kind-minimal-dataspace-cluster --kubeconfig ~/.kube/config_minimalDS -n ds-operator mysql-database-secret -o jsonpath="{.data}" | jq

  kubectl get secret --context kind-minimal-dataspace-cluster --kubeconfig ~/.kube/config_minimalDS -n ds-operator mysql-database-secret -o json | jq -r '.data | to_entries[] | .key + ": " + (.value | @base64d)'

```