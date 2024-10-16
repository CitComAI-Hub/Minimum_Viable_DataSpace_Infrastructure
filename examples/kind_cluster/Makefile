include ./config/deployment.mk

.PHONY: init_apply, destroy

## Init & apply ALL Terraform resources for Kind cluster.
init_apply:
	$(call up_kind,./,../config/cluster.tfvars)
	
## Destroy ALL Terraform resources for Kind cluster.
destroy:
	$(call down_kind,./,../config/cluster.tfvars)
