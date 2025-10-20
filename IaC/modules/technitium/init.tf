terraform {
  required_providers {
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "7.11.2"
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
      Module = "self/open-webui"
    }
  )
}
