FUNCTIONS_FILE?=./common.mk
include $(FUNCTIONS_FILE)

################################################################################
# COMMANDS                                                                     #
################################################################################

.PHONY: init_apply, destroy

## Init & apply Terraform resources.
init_apply:
	terraform init -upgrade
	terraform apply -auto-approve 

## Destroy all Terraform resources.
destroy:
	terraform destroy -auto-approve
	$(remove_tmp_tf)
	rm -rf terraform.tfvars