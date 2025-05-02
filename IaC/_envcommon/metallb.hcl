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
  name             = "metallb"
  chart            = "metallb"
  repository       = "https://metallb.github.io/metallb"
  chart_version    = "0.14.9"
  timeout          = "1500"
  namespace        = "argocd"
  create_namespace = true
}