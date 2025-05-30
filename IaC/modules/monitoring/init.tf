terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.36"
    }
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "7.8.0"
    }
  }
}
locals {
  tags = merge(
    # var.tags,
    {
      Module = "self/monitoring"
    }
  )
}
