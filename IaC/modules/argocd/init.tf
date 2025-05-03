terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}
locals {
  tags = merge(
    # var.tags,
    {
      Module = "self/argocd"
    }
  )
}
