cluster_name = "ds-local-cluster"
flags_deployment = {
    portainer = false,
    cert_trust_manager = false # if it's false, the variable flags_deployment.ca_configuration must also be false
}