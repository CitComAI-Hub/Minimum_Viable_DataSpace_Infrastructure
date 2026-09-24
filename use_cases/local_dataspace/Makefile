.PHONY: init_apply destroy

init_apply:
	$(MAKE) -C ../kind_cluster init_apply
	terraform init -upgrade
	terraform apply -auto-approve

destroy:
	terraform destroy -auto-approve
	$(MAKE) -C ../kind_cluster destroy