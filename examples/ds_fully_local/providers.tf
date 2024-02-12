provider "helm" {
  kubernetes {
    config_path = pathexpand(local.kubernetes_path)
  }
}