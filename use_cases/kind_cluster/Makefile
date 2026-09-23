.PHONY: init_apply, destroy

## Init & apply ALL Terraform resources for Kind cluster.
init_apply:
	terraform init -upgrade && \
	terraform apply -auto-approve
## Destroy ALL Terraform resources for Kind cluster.
destroy:
	terraform destroy -auto-approve
