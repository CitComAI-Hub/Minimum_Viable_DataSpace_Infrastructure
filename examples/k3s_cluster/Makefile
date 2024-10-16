include ../config/common.mk

.PHONY: init_apply, destroy

## Init & apply ALL Terraform resources (cluster + services).
init_apply:
	$(deploy_services)

## Destroy ALL Terraform resources (cluster + services).
destroy:
	terraform destroy -auto-approve
	$(remove_tmp_tf)
	rm kubeconfig.yaml