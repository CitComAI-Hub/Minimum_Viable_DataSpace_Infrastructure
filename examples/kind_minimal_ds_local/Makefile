# include ../config/common.mk
include ../kind_cluster/config/deployment.mk

.PHONY: init_apply, destroy

# export KUBECONFIG=./cluster-config.yaml

## Init & apply Terraform resources for the Kind cluster.
init_apply:
	$(call up_kind,../kind_cluster/,../../kind_minimal_ds_local/config/cluster_vars.tfvars)

	terraform init -upgrade && \
	terraform apply -auto-approve -var-file=./config/global_vars.tfvars

## Destroy Terraform resources for the Kind cluster.
destroy:
	-terraform destroy -auto-approve -var-file=./config/global_vars.tfvars && \
	$(remove_tmp_tf)

	$(call down_kind,../kind_cluster/,../../kind_minimal_ds_local/config/cluster_vars.tfvars)