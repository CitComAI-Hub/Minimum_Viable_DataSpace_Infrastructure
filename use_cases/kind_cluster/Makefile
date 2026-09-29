.PHONY: init_apply destroy cleanup_tailscale

## Cluster name: shared by both layers; the Tailscale operator is named
## <CLUSTER_NAME>-ts-operator in the Tailnet.
CLUSTER_NAME ?= kind-cluster
export TF_VAR_cluster_name := $(CLUSTER_NAME)

## Tailnet devices and Tailscale Services created by this use case: the operator,
## the ProxyGroup replicas (<CLUSTER_NAME>-ingress-N, <CLUSTER_NAME>-egress-N) and
## the Vault service (must match the vault_hostname variable)
TAILSCALE_HOSTNAMES ?= $(CLUSTER_NAME)-ts-operator $(CLUSTER_NAME)-ingress $(CLUSTER_NAME)-egress vault

## Deploys the whole infrastructure in two layers:
##   1. ./     → Kind cluster (writes the kubeconfig)
##   2. apps/  → Tailscale Operator and Vault (reads the kubeconfig)
##
## First removes orphaned devices from a previous deployment, so
## <name>-1, <name>-2, etc. do not pile up in the Tailnet.
init_apply: cleanup_tailscale
	terraform init -upgrade && terraform apply -auto-approve
	cd apps && terraform init -upgrade && terraform apply -auto-approve

## Destroys in reverse order: apps first, then the cluster.
## The operator removes the Tailscale Services and the ProxyGroup devices itself;
## its own device is left orphaned and is removed at the end.
destroy:
	cd apps && terraform destroy -auto-approve
	terraform destroy -auto-approve
	@$(MAKE) cleanup_tailscale

cleanup_tailscale:
	@bash ./cleanup_tailscale.sh $(TAILSCALE_HOSTNAMES) || true
