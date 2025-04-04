# include ../config/common.mk
include ../kind_cluster/config/deployment.mk

.PHONY: init_apply, destroy

# export KUBECONFIG=./cluster-config.yaml

## Init & apply Terraform resources ONLY.
init_apply:
	terraform init -upgrade && \
	terraform apply -auto-approve -var-file=./config/global_vars.tfvars

## Destroy Terraform resources ONLY.
destroy:
	-terraform destroy -auto-approve -var-file=./config/global_vars.tfvars && \
	$(remove_tmp_tf)

## Init & apply Terraform resources for the Kind cluster.
init_cluster:
	$(call up_kind,../kind_cluster/,../../raw_fiware_ds/config/cluster_vars.tfvars)
	terraform init -upgrade && \
	terraform apply -auto-approve -var-file=./config/global_vars.tfvars

## Destroy Terraform resources for the Kind cluster.
destroy_cluster:
	-terraform destroy -auto-approve -var-file=./config/global_vars.tfvars && \
	$(remove_tmp_tf)
	$(call down_kind,../kind_cluster/,../../raw_fiware_ds/config/cluster_vars.tfvars)