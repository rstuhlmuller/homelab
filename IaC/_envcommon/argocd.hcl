locals {

}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "helm_provider" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/providers/helm.hcl"
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/modules/argocd"
}

inputs = {
  name             = "argocd"
  chart            = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart_version          = "7.7.14"
  timeout          = "1500"
  namespace        = "argocd"
  create_namespace = true
}