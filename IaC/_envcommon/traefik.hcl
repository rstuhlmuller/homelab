locals {

}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "helm_provider" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/providers/kube.hcl"
}
include "argocd_provider" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/providers/argocd.hcl"
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/modules/traefik"
}