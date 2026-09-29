.PHONY: init_apply destroy cleanup_tailscale

## Cluster name: shared by both layers; the Tailscale operator is named
## <CLUSTER_NAME>-ts-operator in the Tailnet.
CLUSTER_NAME ?= kind-cluster
export TF_VAR_cluster_name := $(CLUSTER_NAME)

## Deploys the whole infrastructure in two layers:
##   1. ./     → Kind cluster (writes the kubeconfig)
##   2. apps/  → Tailscale Operator (reads the kubeconfig)
##
## First removes the orphaned operator device from a previous deployment,
## so <name>-1, <name>-2, etc. do not pile up in the Tailnet.
init_apply: cleanup_tailscale
	terraform init -upgrade && terraform apply -auto-approve
	cd apps && terraform init -upgrade && terraform apply -auto-approve

## Destroys in reverse order: apps first, then the cluster.
## The operator removes the Ingress proxies itself; the operator device is
## left orphaned and is removed at the end.
destroy:
	cd apps && terraform destroy -auto-approve
	terraform destroy -auto-approve
	@$(MAKE) cleanup_tailscale

cleanup_tailscale:
	@bash ./cleanup_tailscale.sh "$(CLUSTER_NAME)-ts-operator" || true
