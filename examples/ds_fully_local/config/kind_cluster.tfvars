cluster_name = "ds-local-cluster"
flags_deployment = {
    portainer = true,
    cert_trust_manager = true # if it's false, the variable flags_deployment.ca_configuration must also be false
}