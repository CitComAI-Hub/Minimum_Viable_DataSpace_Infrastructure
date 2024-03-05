include ../config/common.mk

WALTID_SCRIPTS_DIR = ../../modules/waltid_ssikit/scripts

################################################################################
# COMMANDS                                                                     #
################################################################################

.PHONY: init_apply, destroy, services_init_apply, services_destroy, cluster_init_apply, cluster_destroy

## Init & apply ALL Terraform resources (cluster + services).
init_apply:
	$(call deploy_cluster,"ds_fully_local")
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
	$(call deploy_cluster,"waltid_didweb")

## Destroy cluster only.
cluster_destroy:
	$(destroy_cluster)