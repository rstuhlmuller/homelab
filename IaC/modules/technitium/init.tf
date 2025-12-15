terraform {
  required_providers {
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "7.12.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
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
