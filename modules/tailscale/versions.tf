terraform {
  required_version = ">= 1.5.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.16"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.33"
    }
    # Applies the ProxyClass and ProxyGroup, whose CRDs are installed in the same apply
    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.1"
    }
  }
}
