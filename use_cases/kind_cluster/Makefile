.PHONY: init_apply destroy cleanup_tailscale

## Despliega la infraestructura completa en dos capas:
##   1. cluster/ → clúster Kind (crea el kubeconfig)
##   2. apps/    → aplicaciones Helm (lee el kubeconfig ya creado)
##
## Limpia previamente cualquier operador huérfano de Tailscale para
## evitar que se acumulen dispositivos (tailscale-operator-1, -2, etc.).
init_apply: cleanup_tailscale
	terraform init -upgrade && terraform apply -auto-approve
	cd apps && terraform init -upgrade && terraform apply -auto-approve

## Destruye en orden inverso: primero apps, luego el clúster.
## Al final elimina automáticamente las máquinas de Tailscale asociadas al clúster.
destroy:
	cd apps && terraform destroy -auto-approve
	terraform destroy -auto-approve
	@$(MAKE) cleanup_tailscale

## Limpia de Tailscale los dispositivos del operador y proxies huérfanos
cleanup_tailscale:
	@bash ./cleanup_tailscale.sh 2>/dev/null || true
