terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "7.12.4"
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
