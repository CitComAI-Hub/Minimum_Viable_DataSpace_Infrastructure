# This layer is applied AFTER the cluster layer has written the kubeconfig.
# ../cluster-config.yaml already exists when this configuration runs, so the
# providers initialise correctly without -target.

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

# Applies custom resources (SecretStore, ExternalSecret) whose CRDs are installed in this same apply
provider "kubectl" {
  config_path      = var.kubeconfig_path
  load_config_file = true
}
