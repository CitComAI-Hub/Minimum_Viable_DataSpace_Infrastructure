include ../config/common.mk

PATH_NAME := "minimal_ds"

################################################################################
# COMMANDS                                                                     #
################################################################################

.PHONY: init_apply, destroy, services_init_apply, services_destroy, cluster_init_apply, cluster_destroy

## Init & apply ALL Terraform resources (cluster + services).
init_apply:
	$(call deploy_cluster,${PATH_NAME})
	$(deploy_services)

## Destroy ALL Terraform resources (cluster + services).
destroy:
	-$(destroy_services)
	$(call destroy_cluster,${PATH_NAME})

## Deploy services only.
services_init_apply:
	$(deploy_services)

## Destroy services only.
services_destroy:
	$(destroy_services)

## Deploy cluster only.
cluster_init_apply:
	$(call deploy_cluster,${PATH_NAME})

## Destroy cluster only.
cluster_destroy:
	$(call destroy_cluster,${PATH_NAME})
