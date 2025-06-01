locals {
  common_vars  = yamldecode(file(find_in_parent_folders("common.yml")))
  project_name = local.common_vars.project_name
}

dependencies {
  paths = ["${dirname(find_in_parent_folders("region.hcl"))}/argocd"]
}

generate "argocd_provider" {
  path      = "argocd_provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
data "aws_ssm_parameter" "argocd_app_token" {
  name = "/${lower(local.project_name)}/argocd/argocd_app_token"
}
provider "argocd" {
  server_addr = "argocd.stinkyboi.com"
  auth_token  = data.aws_ssm_parameter.argocd_app_token.value
}
EOF
}
