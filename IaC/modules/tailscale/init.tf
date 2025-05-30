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
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
locals {
  tags = merge(
    # var.tags,
    {
      Module = "self/tailscale"
    }
  )
}
