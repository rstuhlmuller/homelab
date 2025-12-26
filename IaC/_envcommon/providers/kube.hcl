generate "kube_provider" {
  path      = "kube_provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "kubernetes" {
  host        = "https://10.1.0.199:6443"
  config_path = "~/.kube/config"
}
EOF
}
