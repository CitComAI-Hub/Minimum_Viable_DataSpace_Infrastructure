.PHONY: init_apply destroy cleanup_tailscale

## Nombre del clúster: se comparte con las dos capas y nombra al operador de
## Tailscale en la Tailnet como <CLUSTER_NAME>-ts-operator.
CLUSTER_NAME ?= kind-cluster
export TF_VAR_cluster_name := $(CLUSTER_NAME)

## Despliega la infraestructura completa en dos capas:
##   1. ./     → clúster Kind (crea el kubeconfig)
##   2. apps/  → Tailscale Operator (lee el kubeconfig ya creado)
##
## Antes limpia el dispositivo huérfano del operador de un despliegue anterior,
## para que no aparezcan <nombre>-1, <nombre>-2, etc. en la Tailnet.
init_apply: cleanup_tailscale
	terraform init -upgrade && terraform apply -auto-approve
	cd apps && terraform init -upgrade && terraform apply -auto-approve

## Destruye en orden inverso: primero apps, luego el clúster.
## Los proxies de los Ingress los borra el propio operador; el dispositivo del
## operador queda huérfano y se elimina al final.
destroy:
	cd apps && terraform destroy -auto-approve
	terraform destroy -auto-approve
	@$(MAKE) cleanup_tailscale

cleanup_tailscale:
	@bash ./cleanup_tailscale.sh "$(CLUSTER_NAME)-ts-operator" || true
