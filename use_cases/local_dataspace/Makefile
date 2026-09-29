.PHONY: init_apply destroy cleanup_tailscale

## Hostnames de los Ingress de este caso de uso en la Tailnet
## (deben coincidir con las variables trust_anchor_*_hostname)
TAILSCALE_HOSTNAMES ?= tir til

init_apply:
	$(MAKE) -C ../kind_cluster init_apply
	@$(MAKE) cleanup_tailscale
	terraform init -upgrade
	terraform apply -auto-approve

destroy:
	terraform destroy -auto-approve
	$(MAKE) -C ../kind_cluster destroy

## Elimina dispositivos huérfanos de un clúster anterior borrado sin "make destroy",
## para que los Ingress no se registren como <hostname>-1 y cambien sus URLs
cleanup_tailscale:
	@bash ../kind_cluster/cleanup_tailscale.sh $(TAILSCALE_HOSTNAMES) || true
