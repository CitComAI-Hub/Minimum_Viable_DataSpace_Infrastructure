provider "helm" {
  kubernetes {
    config_path = pathexpand(var.kubeconfig_path)
  }
}

provider "kubernetes" {
  config_path = pathexpand(var.kubeconfig_path)
}

# Applies the External Secrets custom resources of modules/vault/consumer
provider "kubectl" {
  config_path      = pathexpand(var.kubeconfig_path)
  load_config_file = true
}
