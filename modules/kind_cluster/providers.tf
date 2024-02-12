provider "kubernetes" {
  config_path = pathexpand(var.kubernetes_local_path)
}
