locals {
  common_vars  = yamldecode(file(find_in_parent_folders("common.yml")))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals

  region       = local.region_vars.region
  region_short = local.region_vars.region_short
  account_name = local.account_vars.account_name
  project_name = local.common_vars.project_name
  date         = formatdate("EEE MMM DD hh:mm:ss ZZZ YYYY", timestamp())
}

terraform {
  extra_arguments "gen_plan" {
    commands  = ["plan"]
    arguments = ["-out", "plan.out"]
  }
  before_hook "before_hook" {
    commands = ["apply", "plan"]
    execute  = ["echo", "Running Terraform in ${path_relative_to_include()}"]
  }
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = lower("${local.account_name}-aws-use1-s3-tf-state")
    key            = "${lower(local.project_name)}/${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = lower("${local.account_name}-aws-use1-ddb-tf-state-lock")
  }
}

inputs = {
    project_name = "${local.project_name}"
    account_name = "${local.account_name}"
    region       = "${local.region}"
    region_short = "${local.region_short}"
}