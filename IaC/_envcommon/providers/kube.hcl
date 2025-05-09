generate "kube_provider" {
  path      = "kube_provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "kubernetes" {
  config_path = "~/.kube/config"
}
EOF
}