locals {

}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "kube_provider" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/providers/kube.hcl"
}
include "helm_provider" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/providers/helm.hcl"
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/modules/metrics"
}
