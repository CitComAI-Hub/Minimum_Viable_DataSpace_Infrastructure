terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25.2"
    }
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.2.1"
    }
  }
}
