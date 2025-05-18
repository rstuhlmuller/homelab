locals {

}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "helm_provider" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/providers/helm.hcl"
}
include "kube_provider" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/providers/kube.hcl"
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/modules/traefik"
}

dependencies {
  paths = [
    "${dirname(find_in_parent_folders("region.hcl"))}/metallb",
    "${dirname(find_in_parent_folders("region.hcl"))}/longhorn"
  ]
}
