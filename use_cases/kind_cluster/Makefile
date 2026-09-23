.PHONY: init_apply destroy

## Despliega la infraestructura completa en dos capas:
##   1. cluster/ → clúster Kind (crea el kubeconfig)
##   2. apps/    → aplicaciones Helm (lee el kubeconfig ya creado)
##
## Las dos capas son root modules independientes, lo que evita el problema
## de inicialización de providers que ocurre cuando providers que dependen
## de recursos están en el mismo root module que esos recursos.
init_apply:
	terraform init -upgrade && terraform apply -auto-approve
	cd apps && terraform init -upgrade && terraform apply -auto-approve

## Destruye en orden inverso: primero apps, luego el clúster.
destroy:
	cd apps && terraform destroy -auto-approve
	terraform destroy -auto-approve
