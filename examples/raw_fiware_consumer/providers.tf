provider "kubernetes" {
  config_path    = pathexpand(var.kubernetes_local_path)
  config_context = "kind-${var.cluster_name}"
}

provider "helm" {
  kubernetes {
    config_path    = pathexpand(var.kubernetes_local_path)
    config_context = "kind-${var.cluster_name}"
  }
}
