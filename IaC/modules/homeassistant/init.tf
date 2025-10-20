terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.36"
    }
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "7.11.2"
    }
  }
}
locals {
  tags = merge(
    # var.tags,
    {
      Module = "self/open-webui"
    }
  )
}
