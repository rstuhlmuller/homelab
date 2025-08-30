locals {

}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "kube_provider" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/providers/kube.hcl"
}
include "argocd_provider" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/providers/argocd.hcl"
}
include "aws_provider" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/providers/aws.hcl"
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/modules/cloudflare-tunnel"
}
