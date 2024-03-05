locals {
  kubernetes_path = "~/.kube/config"
}

#! Use makefile command to create a local k8s cluster.

module "local_ds_operator" {
  source     = "../../modules/ds_operator/"
  providers = {
    helm = helm
  }

  namespace = "ds-operator"
}
