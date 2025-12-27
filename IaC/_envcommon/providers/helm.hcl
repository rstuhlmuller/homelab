generate "helm_provider" {
  path      = "helm_provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "helm" {
  kubernetes = {
    config_path = pathexpand("~/.kube/config")
  }
}
EOF
}
