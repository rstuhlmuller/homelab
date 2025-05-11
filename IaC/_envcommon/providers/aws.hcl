locals {
  common_vars  = yamldecode(file(find_in_parent_folders("common.yml")))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals

  default_tags = merge(
    local.common_vars.default_tags,
    local.account_vars.default_tags,
    local.region_vars.default_tags,
  )
}

generate "aws_provider" {
  path      = "aws_provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = "us-west-2"
  default_tags {
    tags = ${jsonencode(local.default_tags)}
  }
}
EOF
}
