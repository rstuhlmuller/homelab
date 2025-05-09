terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "~> 7.7"
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
