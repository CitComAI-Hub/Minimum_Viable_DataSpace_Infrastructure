include ../config/common.mk

.PHONY: init_apply, destroy

## Init & apply ALL Terraform resources (cluster + services).
init_apply:
	terraform init && terraform apply -target=module.local_k8s_cluster -auto-approve && terraform apply -auto-approve
## Destroy ALL Terraform resources (cluster + services).
destroy:
	terraform destroy -auto-approve
	$(remove_tmp_tf)