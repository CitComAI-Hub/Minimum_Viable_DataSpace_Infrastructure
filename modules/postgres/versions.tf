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
    # Required by modules/vault/consumer
    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.1"
    }
  }
}
