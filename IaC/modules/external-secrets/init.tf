terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.36"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}
locals {
  tags = merge(
    # var.tags,
    {
      Module = "self/external-secrets"
    }
  )
}
