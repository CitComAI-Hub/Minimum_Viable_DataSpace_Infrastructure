# Vault

Secrets platform for the cluster: [HashiCorp Vault](https://developer.hashicorp.com/vault) plus [External Secrets Operator](https://external-secrets.io) (ESO), fully automated with no manual steps after `terraform apply`.

## What it deploys

- **Vault** (standalone, file storage on a PVC), with its UI/API exposed through an Ingress (`https://vault.<your-tailnet>.ts.net` with the `tailscale` class).
- **External Secrets Operator**, which syncs Vault values into Kubernetes Secrets.
- **Bootstrap** (`bootstrap.sh`, a Deployment in the Vault namespace), a small reconciler that:
  - initialises Vault on first start and stores the unseal key and root token in the `vault-init` Secret;
  - unseals Vault whenever it restarts sealed;
  - enables KV v2 at `secret/` and the Kubernetes auth method;
  - reconciles the consumers registered with the `consumer` submodule (policy, role and secret values), and removes the role and policy of consumers that disappear. KV data is never deleted.

The bootstrap pod is only Ready while Vault is unsealed and configured, and Terraform waits for it, so when `apply` finishes Vault is usable.

Random values (`generated_fields`) are generated inside the cluster, so they never end up in the Terraform state.

## Declaring the secrets of a service

Each service declares what it needs with the `consumer` submodule. It creates, in the service namespace, a ServiceAccount, a SecretStore and one ExternalSecret per Kubernetes Secret, and waits until the Secrets are synced:

```hcl
module "til_secrets" {
  source = "../../modules/vault/consumer"

  name      = "til"
  namespace = "trust-anchor" # must already exist

  secrets = {
    "til-postgres-credentials" = {
      vault_path       = "postgres/til"
      static           = { username = "til" }
      generated_fields = ["password"]
    }
  }
}
```

Two consumers can share a `vault_path` (e.g. a database and its client) with the same definition, and both receive the same generated value.

The use case needs the `kubernetes` and `alekc/kubectl` providers configured with the cluster kubeconfig. The SecretStore and ExternalSecret are applied with `kubectl_manifest`, so their CRDs do not need to exist at plan time:

```hcl
provider "kubectl" {
  config_path      = var.kubeconfig_path
  load_config_file = true
}
```

## Access

- In-cluster address: `http://vault.vault.svc.cluster.local:8200`
- Root token: see the `root_token_command` output.

## Limitations

Intended for local and development environments: the unseal key and the root token are stored in a Kubernetes Secret in the Vault namespace. A production setup should use auto-unseal (cloud KMS or transit) and not keep the root token.
