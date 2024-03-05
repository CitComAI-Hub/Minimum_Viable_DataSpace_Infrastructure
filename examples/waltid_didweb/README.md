# WaltID API service & DID Web server

> **Warning**: Check that scripts have execution permissions.

## Resources

- Kind Cluster:
    - Ingress Nginx.
    - Load Balancer (Metallb).
    - Cert-Manager.
    - Trust-Manager.
- Services:
    - WaltID API service.
    - DID Web server.

## Usage

Deploy or destroy **all** resources:

```bash
make init_apply
```

```bash
make destroy
```

Deploy or destroy **only** Kind cluster:

```bash
make cluster_init_apply
```

```bash
make cluster_destroy
```

Deploy or destroy **only** services:

```bash
make services_init_apply
```

```bash
make services_destroy
```

## K8s important commands

### Get certificate

List all certificates created by cert-manager:

```bash
kubectl get certificate -n <namespace>
```

### Enter in a pod

```bash
kubectl exec -it <pod_name> -n <namespace> -- /bin/bash
```

## WaltID commands

- List DIDs:
    ```bash
    ./bin/waltid-ssikit did list
    ```
- Delete DID:
    ```bash
    ./bin/waltid-ssikit did delete --did did:web:www.upv.example
    ```
- Create DID key:
    ```bash
    ./bin/waltid-ssikit did create --domain www.upv.example
    ```
- Create DID web:
    ```bash
    ./bin/waltid-ssikit did create --domain www.upv.example -m web
    ```
- Resolve DID:
    ```bash
    ./bin/waltid-ssikit did resolve --did did:web:www.upv.example
    ```