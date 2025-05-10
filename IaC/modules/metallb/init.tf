terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.36"
    }
  }
}
locals {
  tags = merge(
    # var.tags,
    {
      Module = "self/metallb"
    }
  )
}
