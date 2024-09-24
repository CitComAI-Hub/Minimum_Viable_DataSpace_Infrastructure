SHELL := /bin/bash

include ../config/common.mk

INGRESS_PROXY = nginx_ingress # nginx_ingress or traefik_ingress

#show current directory
# $(info "Current directory: $(CURDIR)")

define up_kind
	cd $(1)cluster && \
	terraform init -upgrade && \
	terraform apply -auto-approve -var-file=$(2)

	cd $(1)load_balancer && \
	terraform init -upgrade && \
	terraform apply -auto-approve -auto-approve  -var-file=$(2)

	cd $(1)$(INGRESS_PROXY) && \
	terraform init -upgrade && \
	terraform apply -auto-approve -auto-approve  -var-file=$(2)

	cd $(1)cert_trust_manager/ && \
	terraform init -upgrade && \
	terraform apply -auto-approve  -var-file=$(2)
	
	cd $(1)ca_configuration/ && \
	terraform init -upgrade && \
	terraform apply -auto-approve  -var-file=$(2)
endef

define down_kind
	-cd $(1)ca_configuration && \
	terraform destroy -auto-approve  -var-file=$(2) && \
	$(remove_tmp_tf)

	-cd $(1)cert_trust_manager && \
	terraform destroy -auto-approve  -var-file=$(2) && \
	$(remove_tmp_tf)

	-cd $(1)load_balancer && \
	terraform destroy -auto-approve  -var-file=$(2) && \
	$(remove_tmp_tf)

	-cd $(1)$(INGRESS_PROXY) && \
	terraform destroy -auto-approve  -var-file=$(2) && \
	$(remove_tmp_tf)

	-cd $(1)cluster && \
	terraform destroy -auto-approve  -var-file=$(2) && \
	$(remove_tmp_tf) && \
	tmp_path=$$(grep kubernetes_local_path $(2) | cut -d'=' -f2 | tr -d '[:space:]' | tr -d '"') && \
	rm $$tmp_path
endef