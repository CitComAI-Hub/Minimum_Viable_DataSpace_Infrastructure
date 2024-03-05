include ../config/common.mk

WALTID_SCRIPTS_DIR = ../../modules/waltid_ssikit/scripts

define deploy_cluster
	@cd ../kind_cluster && \
		terraform init -upgrade && \
		terraform apply -auto-approve -var-file="../waltid_didweb/config/kind_cluster.tfvars"
endef

define destroy_cluster
	@cd ../kind_cluster && \
		terraform destroy -auto-approve && \
		$(remove_tmp_tf) && \
		rm -rf terraform.tfvars
endef

define deploy_services
	@export CLUSTER_NAME=`grep 'cluster_name' ./config/kind_cluster.tfvars | cut -d'=' -f2 | tr -d ' "'` && \
		bash $(WALTID_SCRIPTS_DIR)/get_kind_cluster_properties.sh $$CLUSTER_NAME && \
		terraform init -upgrade && \
		terraform apply -auto-approve 
endef

define destroy_services
	terraform destroy -auto-approve
	$(remove_tmp_tf)
	rm -rf terraform.tfvars
endef

################################################################################
# COMMANDS                                                                     #
################################################################################

.PHONY: init_apply, destroy, services_init_apply, services_destroy, cluster_init_apply, cluster_destroy

## Init & apply ALL Terraform resources (cluster + services).
init_apply:
	$(deploy_cluster)
	$(deploy_services)

## Destroy ALL Terraform resources (cluster + services).
destroy:
	-$(destroy_services)
	$(destroy_cluster)

## Deploy services only.
services_init_apply:
	$(deploy_services)

## Destroy services only.
services_destroy:
	$(destroy_services)

## Deploy cluster only.
cluster_init_apply:
	$(deploy_cluster)

## Destroy cluster only.
cluster_destroy:
	$(destroy_cluster)