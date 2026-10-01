.PHONY: init_apply destroy cleanup_tailscale

## Tailnet hostnames of the Ingresses in this use case
## (must match the *_hostname variables)
TAILSCALE_HOSTNAMES ?= tir til onboarding-admin onboarding

init_apply:
	$(MAKE) -C ../kind_cluster init_apply
	@$(MAKE) cleanup_tailscale
	terraform init -upgrade
	terraform apply -auto-approve

destroy:
	terraform destroy -auto-approve
	$(MAKE) -C ../kind_cluster destroy

## Removes orphaned devices from a previous cluster deleted without "make destroy",
## so the Ingresses do not register as <hostname>-1 and change their URLs
cleanup_tailscale:
	@bash ../kind_cluster/cleanup_tailscale.sh $(TAILSCALE_HOSTNAMES) || true
