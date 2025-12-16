locals {
  version = "dev"
}

unit "namespace" {
  source = "git::https://github.com/rstuhlmuller/terragrunt-catalog.git//units/kubernetes_namespace?ref=${local.version}"
  path   = "namespace"

  values = {
    name = "argocd"
  }
}

unit "helm_release" {
  source = "git::https://github.com/rstuhlmuller/terragrunt-catalog.git//units/helm_release?ref=${local.version}"
  path   = "helm_release"

  values = {
    version               = local.version
    namespace_config_path = "../namespace"
    name                  = "argocd"
    chart                 = "argo-cd"
    repository            = "https://argoproj.github.io/argo-helm"
  }
}
