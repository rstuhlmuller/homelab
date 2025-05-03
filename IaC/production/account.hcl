locals {
  account_name = "production"
  default_tags = {
    Env = "${local.account_name}"
  }
}